# Certificate Directory

This folder is intentionally left blank.

The Docker container will utilize this directory to generate the Certificate Authority (CA) and other certificate-related files as part of its operation.

## Important Notes

- Ensure this directory remains writable by the Docker container.
- Generated certificates and related files will be stored here during runtime.
- Do not manually add or remove files in this folder unless you understand the impact on the container's operation.
- this is part of .gitignore to prevnt the accidental commit of sensitive information.

For more details, refer to the project documentation.
