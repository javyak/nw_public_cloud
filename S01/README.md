# IoT Registration for WiFi Access

The project will deploy a simple web site with back-end database running on a database server. 

The main characteristics are:

The webserver will be used to register MAC addresses associated to company users so they are allowed to use the WiFi Network though MAC authentication.

The service will be offered through a public Internet facing web server, there's no need for the users to use a private connection.

The tool will use a database that stores the registered MAC addresses associated to users. Each user will be able to access the webserver to add, remove or modify MAC address previosly registered. Another function of the tool will update the Radius server with the new registered MAC addresses so the WiFi network allows them. The Radius server will be offered in the cloud as part of the solution.

User authentication is based on Active Directory, located on prem. 

Only necessary traffic will be allowed from users to the web server, and between the different components. Administration of the servers will be restricted to the internal administration subnet.

The tool is not business critical and can reside in a single Region. However, more than one AZ is recommended for sufficient redundancy. Load Balancers may be required.

The connection between on-prem and the cloud systems will be delivered through VPN as the traffic is expected to be low (AD authentication and administration).
