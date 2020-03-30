## Cloud IP Ranges

Most big cloud providers publish their IP addresses ranges. Information whether an IP address belongs to a particular cloud provider
might be valuable for various reasons, e.g. as a hint for a suspicious request in our context.  

We provide a simple Python script which purpose is to gather the actual IP ranges for various cloud providers.

The script package is available as an asset in [each release of Nixer Spring Plugin](https://github.com/nixer-io/nixer-spring-plugin/releases/latest),
you can also see the source code [here](https://github.com/nixer-io/nixer-spring-plugin/tree/master/scripts/ip_cloud_ranges).
 
#### Supported cloud providers

- AWS
- Azure
- Google Cloud Engine
- IBM cloud
- Cloudflare
- Oracle cloud
  
#### Usage

1. Make sure you have `pipenv` installed. In case you were not familiar with this tool go [here](https://github.com/pypa/pipenv).

2. Setup Python virtual environment
```
pipenv install
```

3. Run the script
```
pipenv run python cloud-ip-ranges.py
```

4. See help for full set of options
```
pipenv run python cloud-ip-ranges.py --help
```
