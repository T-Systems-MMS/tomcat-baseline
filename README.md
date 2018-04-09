# tomcat-baseline
[![Build Status](http://img.shields.io/travis/T-Systems-MMS/tomcat-baseline.svg)][1]


This Inspec Profile tries to ensure compliance of an Apache Tomcat installation along the [Deutsche Telekom, Group IT Security, Security Requirements]().

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

## License and Author

* Author::  Sebastian Gumprich <sebastian.gumprich@t-systems.com>


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
