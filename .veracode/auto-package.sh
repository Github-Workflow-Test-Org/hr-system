#!/bin/bash
set -e

CREATE_PLSQLA_ARCHIVES=true # Set to true to create .plsqla archives for SQL Simple Scanner; otherwise, .zip files will be created.

# Determine source and target directories.
pushd $(dirname "$0") >/dev/null 2>&1
repo_root=`git rev-parse --show-toplevel`
output_dir="$repo_root/.veracode/output/auto"
popd

if [ -d "$output_dir" ]; then
    echo Deleting $output_dir directory...
    rm -rf $output_dir
fi

# Run the packager.
veracode package --source $repo_root --type directory --output $output_dir --trust

# Rename the packaged SQL archive to have a .plsqla extension to be recognized by the SQL simple scanner.
if [ "${CREATE_PLSQLA_ARCHIVES:-false}" = "true" ]; then
    for file in "$output_dir"/*-sql.zip; do
        [ -f "$file" ] && mv "$file" "${file%.zip}.plsqla"
    done
else
    echo "Skipping .plsqla conversion (CREATE_PLSQLA_ARCHIVES is not set to true)"
fi

# To scan the packaged file with SQL Simple Scanner, run:
# java -Dlog4j2.configurationFile=log4j2.yaml \
#      -DsqlScanner.log.name=.veracode/output/auto/sql.log \
#      -jar build/libs/SqlScanner-all.jar \
#      --inputFile .veracode/output/auto/veracode-auto-pack-plsqlsimplescanner-sql.plsqla \
#      --resultsFile .veracode/output/auto/scan-results.xml
