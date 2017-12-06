{
    "type": "hlfv1",
    "name": "hlfv1",
    "orderers": [
        {
            "url": "grpc://{{ $.Values.orderers.service.name }}:{{ $.Values.orderers.service.externalPort }}"
        }
    ],
