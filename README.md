**DISCLAIMER**: I AM NOT RESPONSIBLE OF THE MISUSE OF THIS TOOL. YOU RUN IT AT YOUR OWN RISK. Before running it, make sure you are in a controlled environment, and where you are allowed to perform this kind of exercise. PLEASE BE KIND :)

# blindsqli
A really simple script for boolean-blind SQLi exploitation of vulnerable GET parameters

![alt text](https://github.com/chesire-cat/blindsqli/blob/main/images/blindsqli.png?raw=true)

## Usage
  Syntax: `./blindsqli.sh 'http[s]://<URL>?<vulnparam>=<paramvalue>' '<SQL query>' '<String which appears when TRUE condition>'`
  
  > Notice that the vulnerable GET parameter should be at the end of the URL. In the example below, _id_ is the vulnerable GET paramenter.
  
  Example: `./blindsqli.sh 'http://vulnerable.site/sqli.php?Submit=Submit&id=1234' 'SELECT concat(username,":",password) FROM awd.accounts LIMIT 1,1' 'JohnDoe'"`
    
## TODOs
  - [ ] Target POST parameters.
  - [ ] Optimization.
