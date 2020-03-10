# tomcat-baseline
[![Build Status](http://img.shields.io/travis/T-Systems-MMS/tomcat-baseline.svg)][1]


This Inspec Profile tries to ensure compliance of an Apache Tomcat installation along the [Deutsche Telekom, Group IT Security, Security Requirements](https://www.telekom.com/psa) - 3_39_Tomcat_Application_Server.

## Standalone Usage

This Compliance Profile requires [InSpec](https://github.com/chef/inspec) for execution:

```
$ git clone https://github.com/T-Systems-MMS/tomcat-baseline
$ inspec exec tomcat-baseline
```

You can also execute the profile directly from Github:

```
$ inspec exec https://github.com/T-Systems-MMS/tomcat-baseline
```

It also can be executed inside Docker image with overridden default values. Here is an example for default Tomcat 9 ([`9-jdk11-openjdk-slim`](https://hub.docker.com/_/tomcat)) settings:

```bash
inspec exec tomcat-baseline/ --input catalina_home=/usr/local/tomcat tomcat_conf=/usr/local/tomcat/conf tomcat_libs=/usr/local/tomcat/lib tomcat_logs=/usr/local/tomcat/logs tomcat_cache=/usr/local/tomcat/temp logging_filehandler=AsyncFileHandler tomcat_service=disable
```

## License and Author

* Author:  Sebastian Gumprich <sebastian.gumprich@t-systems.com>


Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

[1]: http://travis-ci.org/T-Systems-MMS/tomcat-baseline
