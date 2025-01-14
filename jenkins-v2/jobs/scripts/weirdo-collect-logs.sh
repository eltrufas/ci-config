# weirdo-collect-logs.sh
# A script to collect logs generated by a weirdo job
pushd $WORKSPACE
export LOG_DISPLAY_URL="https://logserver.rdoproject.org/ci.centos.org/${JOB_NAME}/${BUILD_NUMBER}"
export DESTINATION="/var/www/logs/ci.centos.org/${JOB_NAME}/${BUILD_NUMBER}"

# Install dependencies
[[ ! -d provision_venv ]] && python3 -m venv provision_venv
source provision_venv/bin/activate
pip install -U pip
# Workaround https://github.com/pypa/pip/issues/7667
export LANG=en_US.UTF8
pip install ansible==2.9.16 'Django<2.2' ara[server] shade

export ANSIBLE_HOST_KEY_CHECKING=False
export ANSIBLE_CALLBACK_PLUGINS="$(python3 -m ara.setup.callback_plugins)"
export ARA_DATABASE_NAME="$WORKSPACE/$JOB_NAME.sqlite"

# Recover console log, generate and upload ARA report
ara-manage generate "${WORKSPACE}/ara" || true

# Copy database (experimental)
mkdir ${WORKSPACE}/ara-database
cp ${WORKSPACE}/${JOB_NAME}.sqlite ${WORKSPACE}/ara-database/ansible.sqlite

deactivate

pushd weirdo
# Don't fail script execution even if log collection fails -- the node needs to be destroyed afterwards
tox -e ansible-playbook -- -vv -i $WORKSPACE/hosts playbooks/logs-ci-centos.yml -e ci_environment=ci-centos || true
popd
popd
