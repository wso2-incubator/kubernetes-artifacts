#!/bin/bash
# ------------------------------------------------------------------------
#
# Copyright 2005-2015 WSO2, Inc. (http://wso2.com)
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License

# ------------------------------------------------------------------------

host=172.17.8.102
default_port=32003
km_port=32009
publisher_port=32012
store_port=32014
gateway_port=32007

prgdir=`dirname "$0"`
script_path=`cd "$prgdir"; pwd`
common_scripts_folder=`cd "${script_path}/../../common/scripts/kubernetes/"; pwd`

# Deploy using default profile
function default {
  bash ${common_scripts_folder}/deploy-kubernetes-service.sh "wso2am" "default"
  bash ${common_scripts_folder}/deploy-kubernetes-rc.sh "wso2am" "default"
  bash ${common_scripts_folder}/wait-until-server-starts.sh "wso2am" "default" "${host}" "${default_port}"
}

# Deploy using separate profiles
function distributed {

    # deploy services

    bash ${common_scripts_folder}/deploy-kubernetes-service.sh "wso2am" "api-key-manager"
    bash ${common_scripts_folder}/deploy-kubernetes-service.sh "wso2am" "api-store"
    bash ${common_scripts_folder}/deploy-kubernetes-service.sh "wso2am" "api-publisher"
    bash ${common_scripts_folder}/deploy-kubernetes-service.sh "wso2am" "gateway-manager"

    # deploy the controllers

    bash ${common_scripts_folder}/deploy-kubernetes-rc.sh "wso2am" "api-key-manager"
    bash ${common_scripts_folder}/wait-until-server-starts.sh "wso2am" "api-key-manager" "${host}" "${km_port}"

    bash ${common_scripts_folder}/deploy-kubernetes-rc.sh "wso2am" "api-store"
    bash ${common_scripts_folder}/wait-until-server-starts.sh "wso2am" "api-store" "${host}" "${store_port}"

    bash ${common_scripts_folder}/deploy-kubernetes-rc.sh "wso2am" "api-publisher"
    bash ${common_scripts_folder}/wait-until-server-starts.sh "wso2am" "api-publisher" "${host}" "${publisher_port}"

    bash ${common_scripts_folder}/deploy-kubernetes-rc.sh "wso2am" "gateway-manager"
    bash ${common_scripts_folder}/wait-until-server-starts.sh "wso2am" "gateway-manager" "${host}" "${gateway_port}"
}

pattern=$1
if [ -z "$pattern" ]
  then
    pattern='default'
fi

if [ "$pattern" = "default" ]; then
  default
elif [ "$pattern" = "distributed" ]; then
  distributed
else
  echo "Usage: ./deploy.sh [default|distributed]"
  echo "ex: ./deploy.sh default"
  exit 1
fi
