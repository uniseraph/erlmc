1. register a app
 
 curl http://localhost:8080/register_app/2


2.  subscribe messages from app 1 and property matche a.*
 
 curl http://localhost:8080/subscribe_app/1/a.*
 queue=amq.gen-Q-m09V-BMYH960j7RnHo1r
 receving .....



3.  publish message the app 1

 
 curl http://localhost:8080/publish/1/a.1/aaaaaaa
 curl http://localhost:8080/publish/1/a.2/bbbbbbb


4.  subscribe message reuse queue
 curl http://localhost:8080/subscribe_app/1/a.*/amq.gen-Q-m09V-BMYH960j7RnHo1r
