#!/bin/bash
echo '<!DOCTYPE html>
<html>
<head>
<style>
table {
  font-family: arial, sans-serif;
  border-collapse: collapse;
  width: 100%;
}

td, th {
  border: 1px solid #dddddd;
  text-align: left;
  padding: 8px;
}

tr:nth-child(even) {
  background-color: #dddddd;
}
</style>
</head>
<body>

<h2>Kubernetes Resource Usage Report</h2>

<table>
  <tr>
    <th>Namespace</th>
    <th>quotaname</th>
    <th>limits.cpu.used</th>
    <th>limits.cpu.hard</th>
    <th>limits.memory.used</th>
    <th>limits.memory.hard</th>
    <th>requests.cpu.used</th>
    <th>requests.cpu.hard</th>
    <th>requests.memory.used</th>
    <th>requests.memory.hard</th>
  </tr>' | tee mypage.html 
for ns in $( kubectl get ns | grep -v NAME | awk '{print $1}' )
do
    quota=$( kubectl get quota -n ${ns} 2> /dev/null | grep -v 'CREATED' )
#    if [ "${quota}" == "" ]; then
    if [ "${quota}" = "" ]; then
    echo '<tr><td>'${ns}'</td><td>'empty'</td><td>'0'</td><td>'0'</td><td>'0'</td><td>'0'</td><td>'0'</td><td>'0'</td><td>'0'</td><td>'0'</td></tr>' >> mypage.html
  else
    quotaname=${quota%% *}
        for quotadetail in quotaname
        do
            lc1=$(kubectl describe resourcequota ${quotaname} --namespace=${ns} | egrep -i 'limits.cpu' | awk {'print $2'})
            lc2=$(kubectl describe resourcequota ${quotaname} --namespace=${ns} | egrep -i 'limits.cpu' | awk {'print $3'})
            lm1=$(kubectl describe resourcequota ${quotaname} --namespace=${ns} | egrep -i 'limits.memory' | awk {'print $2'})
            lm2=$(kubectl describe resourcequota ${quotaname} --namespace=${ns} | egrep -i 'limits.memory' | awk {'print $3'})
            rc1=$(kubectl describe resourcequota ${quotaname} --namespace=${ns} | egrep -i 'requests.cpu' | awk {'print $2'})
            rc2=$(kubectl describe resourcequota ${quotaname} --namespace=${ns} | egrep -i 'requests.cpu' | awk {'print $3'})
            rm1=$(kubectl describe resourcequota ${quotaname} --namespace=${ns} | egrep -i 'requests.memory' | awk {'print $2'})
            rm2=$(kubectl describe resourcequota ${quotaname} --namespace=${ns} | egrep -i 'requests.memory' | awk {'print $3'})
            echo "<tr><td>${ns}</td><td>$quotaname</td><td>$lc1</td><td>$lc2</td><td>$lm1</td><td>$lm2</td><td>$rc1</td><td>$rc2</td><td>$rm1</td><td>$rm2</td></tr>" >> mypage.html
          done
      fi
    done  
echo "</table>" >> mypage.html

echo "</body>" >> mypage.html
echo "</html>" >> mypage.html