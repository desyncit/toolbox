#!/bin/bash
 
bash -x deploy.sh -t bootstrap -d bootstrap -n localhost -a 1.1.1.1

printf "Can we bootstrap and install? 1\n" 
read RESP

if [ $RESP = 1 ]; then
  openshift-install wait-for bootstrap-complete --log-level=debug --dir=/etc/containers/okd/4/cluster
  oc get csr -o go-template='{{range .items}}{{if not .status}}{{.metadata.name}}{{"\n"}}{{end}}{{end}}' | xargs oc adm certificate approve
  openshift-install wait-for install-complete --log-level=debug --dir=/etc/containers/okd/4/cluster
fi
