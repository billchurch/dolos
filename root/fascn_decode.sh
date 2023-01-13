#!/usr/bin/env bash
#
# fascn_decode.sh
#
# bill@f5.com 200230113
#
# Simple shell script to convert a hex representation of an FASC-N to decimal and decode the result. This doesn't do any error
# checking of the parity bits
#
# usage:
#   ./fascn_decode.sh <hex>
#
# How does one get the hex value of an FASC-N from a certificate?
#
# 1. `openssl asn1parse -in certificate.pem` 
# 2. Look for the line number after the "X509v3 Subject Alternative Name" object
#   example (876):
#     871:d=5  hl=2 l=   3 prim: OBJECT            :X509v3 Subject Alternative Name
#     876:d=5  hl=3 l= 128 prim: OCTET STRING      [HEX DUMP]:[REDACTED HEX]}
# 3. `openssl asn1parse -in certificate.pem -strparse <line_no_from_above>` 
#  example:
#    openssl asn1parse -in certificate.pem -strparse 876
# 4. Get the "[HEX DUMP]" string in the line after the "2.16.840.1.101.3.6.6" object
#  example (16):
#     4:d=2  hl=2 l=   8 prim: OBJECT            :2.16.840.1.101.3.6.6
#    14:d=2  hl=2 l=  27 cons: cont [ 0 ]        
#    16:d=3  hl=2 l=  25 prim: OCTET STRING      [HEX DUMP]:[REDACTED HEX]
#

[[ ${#1} -eq 50 ]] || { echo >&2 "Hex provided is ${#1} chars long, must be 50."; exit 1; }

# map bcd w/ parity to values, you could do this with bit
# shifting, yet here I am with my clown shoes...
declare -A bcdmap=( ["00001"]="0" ["10000"]="1" ["01000"]="2" ["11001"]="3" ["00100"]="4" ["10101"]="5" ["01101"]="6" ["11100"]="7" ["00010"]="8" ["10011"]="9" ["11010"]="[" ["10110"]="," ["11111"]="]" )

function hexFASCNtoDecimal() {
    # pair of hex vaules
    fascn="$1"
    hexPairs=$(sed 's/.\{2\}/& /g' <<< "$fascn")

    # decimal to binary map
    D2B=({0,1}{0,1}{0,1}{0,1}{0,1}{0,1}{0,1}{0,1})
    # get bcd bits
        # byteInt=$((16#$byteStr))
        # bitStr=$(echo ${D2B[$byteInt]})
        # bits=$bits$bitStr
    bits=""
    for byteStr in $hexPairs
    {
        bits=$bits${D2B[$((16#$byteStr))]}
    }

    # separate bcd bits w/ parity
    bitQuints=$(sed 's/.\{5\}/& /g' <<< "$bits")

    # convert bcd to decimal
    for binaryStr in $bitQuints 
    {
        fascnDecimal="$fascnDecimal${bcdmap[$binaryStr]}"
    }
    echo "$fascnDecimal"
}

fascnDecimal=$(hexFASCNtoDecimal "$1")

# break out the FASC-N into fields
# see https://www.cac.mil/Portals/53/Documents/CAC_NG_Implementation_Guide_v2.6.pdf pp20 for an explanation

# so pretty...
echo "                                Decimal FASC-N: $fascnDecimal"
echo "                              Agency Code (AC): ${fascnDecimal:1:4}"
echo "                              System Code (SC): ${fascnDecimal:6:4}"
echo "                        Credential Number (CN): ${fascnDecimal:11:6}"
echo "                        Credential Series (CS): ${fascnDecimal:18:1}"
echo "             Individual Credential Issue (ICI): ${fascnDecimal:20:1}"
echo "                        Person Identifier (PI): ${fascnDecimal:22:10}"
echo "                  Organizational Category (OC): ${fascnDecimal:32:1}"
echo "                  Organization Identifier (OI): ${fascnDecimal:33:4}"
echo "Person/Organization Association Category (POA): ${fascnDecimal:37:1}"
echo "       Longitudinal Redundancy Character (LRC): ${fascnDecimal:39:1}"

# reversal...
# put your thing down, flip it, and reverse it

# Decimal to FASCN Hex
# Converts decimal FASC-N to BCD
# format: [5700,2008,010785,0,0,9999999999877776]3
function decimalFASCNtoHex() {

    spacer=$(sed 's/.\{1\}/& /g' <<< "$1")
    # echo $spacer
    binStr=""
    for char in $spacer; do 
        mykey=""
        for key in "${!bcdmap[@]}"; do
            if [[ ${bcdmap[$key]} == "$char" ]]; then
                mykey="$mykey$key"
            fi
        done
        binStr="$binStr$mykey"
    done
    fascnhex=""
    for byte in $(sed 's/.\{8\}/& /g' <<< "$binStr")
    {
        fascnhex="$fascnhex$(printf '%02X' "$((2#$byte))")"
    }
    echo $fascnhex

}

newhex=$(decimalFASCNtoHex "$fascnDecimal")

echo -e "\nreversed hex: $newhex"
echo "original hex: $1"
