#!/bin/bash
set -e
shopt -s nullglob

pushd $(dirname "$0") >/dev/null 2>&1
repo_root=`git rev-parse --show-toplevel`
output_dir="$repo_root/.veracode/output/manual"

publishProject() {
    pom_path="$1"

    if [ -d "$output_dir" ]; then
        echo Deleting $output_dir directory...
        rm -rf $output_dir
    fi
    mkdir -p $output_dir

    pushd $pom_path >/dev/null 2>&1
        mvn clean package
        cp target/*.{war,jar,ear} "$output_dir"
    popd
}

packageSqlCode() {
    sql_zip="$output_dir/veracode-manual-pack-hr-system-sql.zip"
    temp_dir=$(mktemp -d)
    trap "rm -rf ${temp_dir}" EXIT

    echo "Packaging SQL files into: $sql_zip"

    # Find all SQL files and copy them to temp directory with relative paths preserved
    pushd $repo_root >/dev/null 2>&1
        find database -name "*.sql" -type f | while read -r sqlfile; do
            target_path="${temp_dir}/${sqlfile}"
            mkdir -p "$(dirname "${target_path}")"
            cp "${sqlfile}" "${target_path}"
        done

        # Create the zip file with relative paths
        cd "${temp_dir}"
        zip -r "${sql_zip}" database/
    popd

    echo "Successfully created SQL package: $sql_zip"
}

publishProject "$repo_root/java-app"
packageSqlCode
