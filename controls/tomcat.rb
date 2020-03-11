input('tomcat_service', value: 'enable')
input('tomcat_user', value: 'tomcat')
input('tomcat_group', value: 'tomcat')
input('catalina_home', value: '/usr/share/tomcat')
input('tomcat_conf', value: '/etc/tomcat')
input('tomcat_libs', value: '/var/lib/tomcat')
input('tomcat_logs', value: '/var/log/tomcat')
input('tomcat_cache', value: '/var/cache/tomcat')
input('logging_filehandler', value: 'FileHandler')

control 'tomcat.dedicated_user' do
  impact 1.0
  tag 'ID: 3.10-5/2.1'
  title 'The application server must run under a dedicated (operating-system) account that only has the permissions required for operation.'
  describe user(input('tomcat_user')) do
    it { should exist }
  end
  describe group(input('tomcat_group')) do
    it { should exist }
  end
end

control 'tomcat.dedicated_service' do
  impact 1.0
  tag 'ID: 3.10-5/2.1-1'
  title 'If not containerized, the application service must be installed properly.'
  describe service('tomcat') do
    before do
      skip if input('tomcat_service') == 'disable'
    end
    it { should be_installed }
    it { should be_enabled }
    it { should be_running }
  end
  describe processes('tomcat') do
    before do
      skip if input('tomcat_service') == 'disable'
    end
    its('users') { should eq [input('tomcat_user')] }
  end
end

# control 'tomcat.unused_services_protocols' do
#   tag 'ID: 3.39-1/2.2'
#   title 'Unused services and protocols must be deactivated.'
#   # connectoren in server.xml mit offenen ports vergleichen
# end

control 'tomcat.shutdownport' do
  impact 1.0
  tag 'ID: 3.39-2/2.2'
  title 'If the shutdown port is not needed, it must be deactivated.'
  describe file(input('tomcat_conf') + '/server.xml') do
    its('content') { should match '<Server port="-1"' }
  end
end

control 'tomcat.autodeploy' do
  tag 'ID: 3.39-4/2.2'
  title 'Automatic deployment of applications must be disabled.'
  describe file(input('tomcat_conf') + '/server.xml') do
    its('content') { should match 'autoDeploy="false"' }
    its('content') { should_not match 'autoDeploy="true"' }
    its('content') { should match 'deployXML="false"' }
    its('content') { should_not match 'deployXML="true"' }
  end
end

control 'tomcat.sensitive_info' do
  impact 1.0
  tag 'ID: 3.01-8/2.2'
  title 'Sensitive information must not be contained in files, outputs or messages that are by unauthorized users accessible.'
  describe file(input('tomcat_conf') + '/server.xml') do
    its('content') { should_not match 'xpoweredBy="true"' }
    its('content') { should_not match 'allowTrace="true"' }
    its('content') { should_not match 'server=" "' }
  end
end

control 'tomcat.sample_apps' do
  impact 1.0
  tag 'ID: 3.39-5/2.2'
  title 'Sample applications and unnecessary standard tools must be deleted.'
  describe directory(input('catalina_home') + '/webapps/js-examples') do
    it { should_not exist }
  end
  describe directory(input('catalina_home') + '/webapps/servlet-example') do
    it { should_not exist }
  end
  describe directory(input('catalina_home') + '/webapps/tomcat-docs') do
    it { should_not exist }
  end
  describe directory(input('catalina_home') + '/webapps/balancer') do
    it { should_not exist }
  end
  describe directory(input('catalina_home') + '/webapps/ROOT/admin') do
    it { should_not exist }
  end
  describe directory(input('catalina_home') + '/webapps/examples') do
    it { should_not exist }
  end
  describe directory(input('catalina_home') + '/server/webapps/host-manager') do
    it { should_not exist }
  end
end

control 'tomcat.manager_app' do
  impact 1.0
  tag 'ID: 3.39-6/2.2'
  title 'If the "manager" application is used, this must be protected against unauthorized use.'
  if File.directory?(input('catalina_home') + '/webapps/manager')
    describe file(input('tomcat_conf') + '/server.xml') do
      its('owner') { should eq input('tomcat_user') }
      its('group') { should eq input('tomcat_group') }
      its('mode') { should cmp '0640' }
      its('content') { should match 'org.apache.catalina.users.MemoryUserDatabaseFactory' }
    end
    describe file(input('tomcat_conf') + '/tomcat-users.xml') do
      its('owner') { should eq input('tomcat_user') }
      its('group') { should eq input('tomcat_group') }
      its('mode') { should cmp '0640' }
      its('content') { should match '<user username=".*"\s+password="([a-f0-9]{40})"\s+roles=".*manager-gui.*"(\s+)?/>' }
    end
  end
end

control 'tomcat.ip_whitelisting' do
  impact 1.0
  tag 'ID: 3.39-7/2.2'
  title 'Access to the application server must only be possible from approved IP addresses (IP whitelisting).'
  describe file(input('tomcat_conf') + '/server.xml') do
    # mit der xml resource testen!
    its('content') { should match 'allow=".*"' }
  end
end

# control 'tomcat.separate_service' do
#   tag 'ID: 3.39-8/2.2'
#   title 'For each application, a separate service must be configured within the application server.'
#     # in webapps nach verzeichnissen suchen und nach den namen in server.xml suchen
# end

control 'tomcat.logging' do
  impact 1.0
  tag 'ID: 3.10-8/2.1'
  title 'Access to the application server must be logged.'
  describe file(input('tomcat_conf') + '/logging.properties') do
    its('content') { should match '.handlers = 1catalina.org.apache.juli.' + input('logging_filehandler') + ', java.util.logging.ConsoleHandler' }
    its('content') { should match '1catalina.org.apache.juli.' + input('logging_filehandler') + '.level = FINE' }
    its('content') { should match '2localhost.org.apache.juli.' + input('logging_filehandler') + '.level = FINE' }
    its('content') { should match 'java.util.logging.ConsoleHandler.level = FINE' }
    its('content') { should match '.level = INFO' }
  end
  describe file(input('tomcat_conf') + '/server.xml') do
    its('content') { should match 'org.apache.catalina.valves.AccessLogValve' }
  end
  describe directory(input('tomcat_logs')) do
    it { should exist }
    it { should be_directory }
    its('mode') { should cmp '0750' }
    it { should be_owned_by input('tomcat_user') }
  end
end

control 'tomcat.directories' do
  impact 1.0
  title 'Check for existence and correct permissions of tomcat directories'
  describe directory(input('catalina_home')) do
    it { should be_directory }
    its('owner') { should eq input('tomcat_user') }
    its('group') { should eq input('tomcat_group') }
    its('mode') { should cmp '0750' }
  end
  describe directory(input('tomcat_conf')) do
    it { should be_directory }
    its('owner') { should eq input('tomcat_user') }
    its('group') { should eq input('tomcat_group') }
    its('mode') { should cmp '0750' }
  end
  describe directory(input('tomcat_logs')) do
    it { should be_directory }
    its('owner') { should eq input('tomcat_user') }
    its('group') { should eq input('tomcat_group') }
    its('mode') { should cmp '0750' }
  end
  describe directory(input('tomcat_libs')) do
    it { should be_directory }
    its('owner') { should eq input('tomcat_user') }
    its('group') { should eq input('tomcat_group') }
    its('mode') { should cmp '0750' }
  end
  describe directory(input('tomcat_cache')) do
    it { should be_directory }
    its('owner') { should eq input('tomcat_user') }
    its('group') { should eq input('tomcat_group') }
    its('mode') { should cmp '0750' }
  end
end

control 'tomcat.files' do
  impact 1.0
  title 'Check for existence and correct permissions of tomcat files'
  describe file(input('tomcat_conf') + '/web.xml') do
    it { should exist }
    it { should be_file }
    its('owner') { should eq input('tomcat_user') }
    its('group') { should eq input('tomcat_group') }
    its('mode') { should cmp '0640' }
  end
  describe file(input('tomcat_conf') + '/context.xml') do
    it { should exist }
    it { should be_file }
    its('owner') { should eq input('tomcat_user') }
    its('group') { should eq input('tomcat_group') }
    its('mode') { should cmp '0640' }
  end
  describe file(input('tomcat_conf') + '/server.xml') do
    it { should exist }
    it { should be_file }
    its('owner') { should eq input('tomcat_user') }
    its('group') { should eq input('tomcat_group') }
    its('mode') { should cmp '0640' }
  end
end

control 'tomcat.listeners' do
  impact 1.0
  title 'Checking enabled listeners'
  describe file(input('tomcat_conf') + '/server.xml') do
    its('content') { should match '<Listener\s+className="org.apache.catalina.core.JreMemoryLeakPreventionListener".*appContextProtection="true".*/>' }
    its('content') { should match '<Listener\s+className="org.apache.catalina.core.ThreadLocalLeakPreventionListener"(\s+)?/>' }
    its('content') { should match '<Listener\s+className="org.apache.catalina.mbeans.GlobalResourcesLifecycleListener"(\s+)?/>' }
    its('content') { should match '<Listener\s+className="org.apache.catalina.security.SecurityListener"(\s+)?/>' }
    its('content') { should match '<Listener\s+className="org.apache.catalina.startup.VersionLoggerListener"(\s+)?/>' }
  end
end

control 'tomcat.lock_out_realm' do
  impact 1.0
  title 'Use the LockOutRealm to prevent attempts to guess user passwords via a brute-force attack'
  describe file(input('tomcat_conf') + '/server.xml') do
    its('content') { should match '<Realm\s+className="org.apache.catalina.realm.LockOutRealm"(\s+)?>' }
  end
end

control 'tomcat.stuck_thread_detection' do
  impact 1.0
  title 'Detect requests that take a long time to process'
  describe file(input('tomcat_conf') + '/server.xml') do
    its('content') { should match '<Valve\s+className="org.apache.catalina.valves.StuckThreadDetectionValve"\s+threshold="\d+"(\s+)?/>' }
  end
end

control 'tomcat.logging_error_reporting' do
  impact 1.0
  title 'Verify that stack traces and server info are not reported'
  describe file(input('tomcat_conf') + '/server.xml') do
    its('content') { should match 'showReport="false"' }
    its('content') { should match 'showServerInfo="false"' }
  end
end

control 'tomcat.crawler_session_manager' do
  impact 1.0
  title 'Ensuring that crawlers are associated with a single session'
  describe file(input('tomcat_conf') + '/server.xml') do
    its('content') { should match 'hostAware="true"' }
    its('content') { should match 'contextAware="true"' }
  end
end

control 'tomcat.health_status' do
  impact 1.0
  title 'Health checks must be disabled'
  describe file(input('tomcat_conf') + '/server.xml') do
    its('content') { should_not match 'org.apache.catalina.valves.HealthCheckValve' }
  end
end

control 'tomcat.http_headers' do
  impact 1.0
  title 'Verifying HTTP headers security (see https://securityheaders.com)'
  describe file(input('tomcat_conf') + '/web.xml') do
    its('content') { should match 'hstsEnabled' }
    # X-Frame-Options
    its('content') { should match 'antiClickJackingEnabled' }
    # X-Content-Type-Options & X-XSS-Protection: 1; mode=block
    its('content') { should match 'blockContentTypeSniffingEnabled' }
    # HttpOnly flag to cookies
    its('content') { should match '<http-only>true</http-only>' }
  end
end
