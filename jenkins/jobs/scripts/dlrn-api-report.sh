virtualenv $WORKSPACE/venv_dlrnapi
source $WORKSPACE/venv_dlrnapi/bin/activate

pip install dlrnapi_client shyaml

curl -sLo $BUILD_TAG.yaml $(echo $DELOREAN_URL | sed 's/delorean\.repo/commit.yaml/')

commit_hash=$(cat $BUILD_TAG.yaml| shyaml get-value commits.0.commit_hash)
distro_hash=$(cat $BUILD_TAG.yaml| shyaml get-value commits.0.distro_hash)

dlrnapi report-result \
    --url https://$DELOREAN_HOST/api-$RDO_VERSION \
    --username ciuser \
    --job-id $JOB_NAME \
    --commit-hash $commit_hash \
    --distro-hash $distro_hash \
    --timestamp $(date +%s) \
    --info-url https://ci.centos.org/artifacts/rdo/$BUILD_TAG/console.txt.gz \
    --success $JOB_SUCCESS