# TEST USE ONLY

### Setup Instructions

* ```git clone https://github.com/toddstoffel/cluster.git```
* ```cd cluster```
* ```docker-compose up```

### Access Containers

* ```docker exec -it mcs1_container bash```
* ```docker exec -it mcs2_container bash```
* ```docker exec -it mcs3_container bash```

### Request Headers Needed:

* 'x-api-key': 'somekey123'
* 'Content-Type': 'application/json'

*Note: x-api-key can be set to any value of your choice during the first call to the server. Subsequent connections will require this same key*

### Examples using curl:

#### Get Status:
```
curl -s https://mcs1:8640/cmapi/0.4.0/cluster/status --header 'Content-Type:application/json' --header 'x-api-key:somekey123' -k | jq .
```
#### Add Node 2:
```
curl -s -X PUT https://mcs1:8640/cmapi/0.4.0/cluster/add-node --header 'Content-Type:application/json' --header 'x-api-key:somekey123' --data '{"timeout":60, "node": "mcs2"}' -k | jq .
```
#### Add Node 3:
```
curl -s -X PUT https://mcs1:8640/cmapi/0.4.0/cluster/add-node --header 'Content-Type:application/json' --header 'x-api-key:somekey123' --data '{"timeout":60, "node": "mcs3"}' -k | jq .
```
#### Remove Node 2:
```
curl -s -X PUT https://mcs1:8640/cmapi/0.4.0/cluster/remove-node --header 'Content-Type:application/json' --header 'x-api-key:somekey123' --data '{"timeout":60, "node": "mcs2"}' -k | jq .
```
#### Remove Node 3:
```
curl -s -X PUT https://mcs1:8640/cmapi/0.4.0/cluster/remove-node --header 'Content-Type:application/json' --header 'x-api-key:somekey123' --data '{"timeout":60, "node": "mcs3"}' -k | jq .
```
#### Stop Cluster:
```
curl -s -X PUT https://mcs1:8640/cmapi/0.4.0/cluster/shutdown --header 'Content-Type:application/json' --header 'x-api-key:somekey123' --data '{"timeout":60}' -k | jq .
```
#### Start Cluster:
```
curl -s -X PUT https://mcs1:8640/cmapi/0.4.0/cluster/start --header 'Content-Type:application/json' --header 'x-api-key:somekey123' --data '{"timeout":60}' -k | jq .
```
