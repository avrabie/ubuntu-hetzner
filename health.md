
```bash
netstat -ano | findstr :30080
```

netsh interface portproxy add v6tov4 listenaddress=:: listenport=30080 connectaddress=127.0.0.1 connectport=30080

netsh interface portproxy show all
netsh interface portproxy delete v6tov4 listenaddress=:: listenport=30080
netsh interface portproxy add v6tov4 listenaddress=:: listenport=80 connectaddress=127.0.0.1 connectport=80