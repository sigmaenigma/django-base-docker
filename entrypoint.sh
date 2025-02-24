#!/bin/bash
# Copy the code to the volume mount location
cp -r /code/* /app
# Run the original command
exec "$@"
