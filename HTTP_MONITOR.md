# NSX-T HTTP Monitor for CockroachDB

1. Log into NSX-T and navigate **Networking > Load Balancing > Monitors**

![NSX-T LB Monitors](images/nsxt-monitor-crdb-http-01.png)
 
2. Click **Add Active Monitor > HTTP**
   
![NSX-T LB Monitors](images/nsxt-monitor-crdb-http-02.png)

3. Fill in the following fields then click **HTTP Request Configure**.

| Field               | Value                | 
| :---                | :----                |   
| Name                | crdb-http-lb-monitor | 
| Monitoring Port     | 8080                 |
| Monitoring Interval | 2                    |
| Timeout Period      | 5                    |
| Tag                 | CockroachDB          |

![NSX-T LB Monitors](images/nsxt-monitor-crdb-http-03.png)

4. On the HTTP Request Configuration tab fill in the following fields.

| Field                | Value           | 
| :---                 | :----           |   
| HTTP Method          | Get             | 
| HTTP Request URL     | /health?ready=1 |
| HTTP Request Version | 1.1             |

![NSX-T LB Monitors](images/nsxt-monitor-crdb-http-04.png)

5. On the HTTP Response Configuration tab fill in the following fields.

| Field                | Value           | 
| :---                 | :----           |   
| HTTP Response Code   | 200             |

![NSX-T LB Monitors](images/nsxt-monitor-crdb-http-05.png)

6. The completed monitor should look like this.

| Field                | Value           | 
| :---                 | :----           |   
| HTTP Response Code   | 200             |
![NSX-T LB Monitors](images/nsxt-monitor-crdb-http-06.png)
   