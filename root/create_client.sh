#!/bin/bash
# Enable automatic exports and error tracing
set -a

# Set and export ROOT first
set -a
ROOT=/app

# Ensure gum is available
if ! command -v gum &> /dev/null; then
    log "gum is not installed"
    exit 1
fi

# Get user input with gum but use direct assignment
NAME=$(gum input --header "Enter name (LAST.FIRST.M)" --value "JOHNSON.ROBERT.A")

EDIPI=$(gum input --header "Enter EDIPI (10 Characters)" --value "4444309999")
# A PIV is comprised of a 10 digit DoD ID # followed by 6 more digits

# The 1st digit is the Organizational Category
# Source:  Paragraph 5.1.5.2.8 https://www.dmdc.osd.mil/smartcard/docs/DoD%20PIV%20Transitional%20Implementation%20Guide.pdf
# Create array of organization category choices
ORG_CHOICES=(
  "1 - Federal Government Agency"
  "2 - State Government Agency" 
  "3 - Commercial Enterprise"
  "4 - Foreign Government"
  "Other - Specify Custom Code"
)

# Present choices using gum choose
SELECTED=$(gum choose --header "Select Organization Category:" "${ORG_CHOICES[@]}")

if [[ "$SELECTED" == "Other - Specify Custom Code" ]]; then
  # Allow custom input if "Other" selected
  ORG_CATEGORY=$(gum input --header "Enter Custom Organization Code (1 digit):" --placeholder "Enter code...")
else
  # Extract just the code from the selection
  ORG_CATEGORY=$(echo "$SELECTED" | cut -d' ' -f1)
fi

# The 2nd through 5th are the Agency Code
# https://www.dmdc.osd.mil/smartcard/docs/DoD%20PIV%20Transitional%20Implementation%20Guide.pdf
# Create array of agency choices
AGENCY_CHOICES=(
  "2100 - Department of the Army"
  "5700 - Department of the Air Force" 
  "1700 - Department of the Navy"
  "1727 - Department of the Navy - US Marine Corps"
  "9700 - Department of Defense - Other Agencies"
  "7008 - US Coast Guard"
  "7520 - US Public Health Service"
  "1330 - National Oceanic and Atmospheric Administration"
  "Other - Specify Custom Code"
)

# Present choices using gum choose
SELECTED=$(gum choose --header "Select Agency Code:" "${AGENCY_CHOICES[@]}")

if [[ "$SELECTED" == "Other - Specify Custom Code" ]]; then
  # Allow custom input if "Other" selected
  AGENCY_CODE=$(gum input --header "Enter Custom Agency Code (4 digits):" --placeholder "Enter code...")
else
  # Extract just the code from the selection
  AGENCY_CODE=$(echo "$SELECTED" | cut -d' ' -f1)
fi

# The 6th position is the Person / Organization Association Category
# Source:  Paragraph 5.1.5.2.10  https://www.dmdc.osd.mil/smartcard/docs/DoD%20PIV%20Transitional%20Implementation%20Guide.pdf
# Create array of person/org association choices
PERSON_CHOICES=(
  "1 - Employee (NAF - Non Appropriated Funds)"
  "2 - Civil (CIV/LN - Civilian/Local National)"
  "3 - Executive Staff"
  "4 - Uniformed Service (MIL - Military)"
  "5 - Contractor (CTR)"
  "6 - Organization Affiliate (NFG/Volunteer/Foreign Military)"
  "7 - Organization Beneficiary"
  "Other - Specify Custom Code"
)

# Present choices using gum choose
SELECTED=$(gum choose --header "Select Person/Organization Association Category:" "${PERSON_CHOICES[@]}")

if [[ "$SELECTED" == "Other - Specify Custom Code" ]]; then
  # Allow custom input if "Other" selected
  PERSON_CAT=$(gum input --header "Enter Custom Category Code (1 digit):" --placeholder "Enter code...")
else
  # Extract just the code from the selection
  PERSON_CAT=$(echo "$SELECTED" | cut -d' ' -f1)
fi

AGENCY=${ORG_CATEGORY}${AGENCY_CODE}${PERSON_CAT}

DAYS=$(gum input --header "Enter Certificate Lifetime (DAYS)" --value "730")

# Get available CAs by listing directories that match CA-* pattern
CA_CHOICES=($(ls -d /app/CA-* | xargs -n1 basename))

# Present choices using gum choose
SIGNINGCA=$(gum choose --header "Select Signing CA:" "${CA_CHOICES[@]}" | cut -d'-' -f2)


# Set all derived variables
FULLPIV=${AGENCY}${EDIPI}
UPN="$EDIPI$AGENCY@mil"
SUBJ="$NAME.$EDIPI"
CN="/C=US/O=U.S. Government/OU=DoD/OU=PKI/OU=USAF/CN="
STARTDATE=$(date -u +"%Y%m%d%H%M%SZ")
ENDDATE=$(date -u -d "${DAYS} days" +"%Y%m%d%H%M%SZ")
URN="$(uuidgen -r | tr "[:lower:]" "[:upper:]")"
CERTSERIAL="030ee92c"
FASCN="$(openssl rand -hex 20 | tr "[:lower:]" "[:upper:]")"
NATIONALITY="3012301006082B06010505070904310413025553"

EXTENSIONS="usr_cert"
# SIGNINGCA="59"
INT_CA_DIR="$ROOT/CA-$SIGNINGCA"
set +a

# Show progress with gum spin
# Replace the single spinner section with individual styled steps

# Generate client private key
if openssl genrsa -out "$INT_CA_DIR/private/$SUBJ.key.pem" 2048 > /dev/null 2>&1; then
    gum style --foreground 82 "✓ Generated private key"
    chmod 400 "$INT_CA_DIR/private/$SUBJ.key.pem" > /dev/null 2>&1
else
    gum style --foreground 196 "✗ Failed to generate private key"
    exit 1
fi

# Create certificate signing request
if openssl req -config /opt/intermediate.conf \
    -key "$INT_CA_DIR/private/$SUBJ.key.pem" \
    -new -sha256 -out "$INT_CA_DIR/csr/$SUBJ.csr.pem" \
    -subj "$CN$SUBJ" > /dev/null 2>&1; then
    gum style --foreground 82 "✓ Created certificate signing request"
else
    gum style --foreground 196 "✗ Failed to create CSR"
    exit 1
fi

# Sign with intermediate CA
if echo -e "y\ny\n" | openssl ca -config /opt/intermediate.conf \
    -extensions $EXTENSIONS -days $DAYS -md sha256 \
    -cert "$ROOT/certs/DoD ID CA-$SIGNINGCA.cert.pem" \
    -keyfile "$ROOT/private/DoD ID CA-$SIGNINGCA.key.pem" \
    -startdate $STARTDATE \
    -enddate $ENDDATE \
    -in "$INT_CA_DIR/csr/$SUBJ.csr.pem" \
    -out "$INT_CA_DIR/certs/$SUBJ.cert.pem" > /dev/null 2>&1; then
    gum style --foreground 82 "✓ Signed certificate with intermediate CA"
else
    gum style --foreground 196 "✗ Failed to sign certificate"
    exit 1
fi

# Set permissions and cleanup
chmod 444 "$INT_CA_DIR/certs/$SUBJ.cert.pem" > /dev/null 2>&1
rm "$INT_CA_DIR/csr/$SUBJ.csr.pem" > /dev/null 2>&1
gum style --foreground 82 "✓ Set permissions and cleaned up temporary files"

# Create summary box
gum style \
  --border double \
  --border-foreground 212 \
  --padding "1 2" \
  --align center \
  "Certificate Generation Summary" \
  "" \
  "$(gum style --foreground 99 'Identity:')" \
  "Name: $(gum style --bold "$NAME")" \
  "EDIPI: $(gum style --bold "$EDIPI")" \
  "FULL PIV: $(gum style --bold "$FULLPIV")" \
  "" \
  "$(gum style --foreground 99 'Generated Files:')" \
  "Certificate: $(gum style --foreground 82 "$INT_CA_DIR/certs/$SUBJ.cert.pem")" \
  "Private Key: $(gum style --foreground 82 "$INT_CA_DIR/private/$SUBJ.key.pem")"
