control 'tomcat.dedicated_user' do
  tag 'ID: 3.10-5/2.1'
  title 'The application server must run under a dedicated (operating-system) account that only has the permissions required for operation.'
  describe service('tomcat') do
    it { should be_installed }
    it { should be_enabled }
    it { should be_running }
  end
  describe user('tomcat') do
    it { should exist }
  end
  describe group('tomcat') do
    it { should exist }
  end
  describe processes('tomcat') do
    its('users') { should eq ['tomcat'] }
  end
end

# control 'tomcat.unused_services_protocols' do
#   tag 'ID: 3.39-1/2.2'
#   title 'Unused services and protocols must be deactivated.'
#   # connectoren in server.xml mit offenen ports vergleichen
# end

control 'tomcat.shutdownport' do
  tag 'ID: 3.39-2/2.2'
  title 'If the shutdown port is not needed, it must be deactivated.'
  describe file('/etc/tomcat/server.xml') do
    its('content') { should match '<Server port="-1"' }
  end
end

control 'tomcat.autodeploy' do
  tag 'ID: 3.39-4/2.2'
  title 'Automatic deployment of applications must be disabled.'
  describe file('/etc/tomcat/server.xml') do
    its('content') { should match 'autoDeploy="false"' }
    its('content') { should_not match 'autoDeploy="true"' }
  end
end

control 'tomcat.sensitive_info' do
  tag 'ID: 3.01-8/2.2'
  title 'Sensitive information must not be contained in files, outputs or messages that are by unauthorized users accessible.'
  describe file('/etc/tomcat/server.xml') do
    its('content') { should_not match 'xpoweredBy="true"' }
    its('content') { should_not match 'allowTrace="true"' }
    its('content') { should_not match 'server=" "' }
  end
end

control 'tomcat.sample_apps' do
  tag 'ID: 3.39-5/2.2'
  title 'Sample applications and unnecessary standard tools must be deleted.'
  describe directory('/usr/share/tomcat/webapps/js-examples') do
    it { should_not exist }
  end
  describe directory('/usr/share/tomcat/webapps/servlet-example') do
    it { should_not exist }
  end
  describe directory('/usr/share/tomcat/webapps/tomcat-docs') do
    it { should_not exist }
  end
  describe directory('/usr/share/tomcat/webapps/balancer') do
    it { should_not exist }
  end
  describe directory('/usr/share/tomcat/webapps/ROOT/admin') do
    it { should_not exist }
  end
  describe directory('/usr/share/tomcat/webapps/examples') do
    it { should_not exist }
  end
  describe directory('/usr/share/tomcat/server/webapps/host-manager') do
    it { should_not exist }
  end
end

# control 'tomcat.manager_app' do
#   tag 'ID: 3.39-6/2.2'
#   title 'If the "manager" application is used, this must be protected against unauthorized use.'
# end

control 'tomcat.ip_whitelisting' do
  tag 'ID: 3.39-7/2.2'
  title 'Access to the application server must only be possible from approved IP addresses (IP whitelisting).'
  describe file('/etc/tomcat/server.xml') do
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
  tag 'ID: 3.10-8/2.1'
  title 'Access to the application server must be logged.'
  describe file('/usr/share/tomcat/conf/logging.properties') do
    its('content') { should match '.handlers = 1catalina.org.apache.juli.FileHandler, java.util.logging.ConsoleHandler' }
    its('content') { should match '1catalina.org.apache.juli.FileHandler.level = FINE' }
    its('content') { should match '2localhost.org.apache.juli.FileHandler.level = FINE' }
    its('content') { should match 'java.util.logging.ConsoleHandler.level = FINE' }
    its('content') { should match '.level = INFO' }
  end
  describe directory('/usr/share/tomcat/logs') do
    it { should exist }
    it { should be_directory }
    its('mode') { should cmp '0750' }
    it { should be_owned_by 'tomcat' }
  end
end

control 'tomcat.directories' do
  title 'Check for existence and correct permissions of tomcat directories'
  describe directory('/usr/share/tomcat') do
    it { should be_directory }
    its('owner') { should eq 'tomcat' }
    its('group') { should eq 'tomcat' }
    its('mode') { should cmp '0750' }
  end
  describe directory('/etc/tomcat') do
    it { should be_directory }
    its('owner') { should eq 'tomcat' }
    its('group') { should eq 'tomcat' }
    its('mode') { should cmp '0750' }
  end
  describe directory('/var/log/tomcat') do
    it { should be_directory }
    its('owner') { should eq 'tomcat' }
    its('group') { should eq 'tomcat' }
    its('mode') { should cmp '0750' }
  end
  describe directory('/var/lib/tomcat') do
    it { should be_directory }
    its('owner') { should eq 'tomcat' }
    its('group') { should eq 'tomcat' }
    its('mode') { should cmp '0750' }
  end
  describe directory('/var/cache/tomcat') do
    it { should be_directory }
    its('owner') { should eq 'tomcat' }
    its('group') { should eq 'tomcat' }
    its('mode') { should cmp '0750' }
  end
end

control 'tomcat.files' do
  title 'Check for existence and correct permissions of tomcat files'
  describe file('/usr/share/tomcat/conf/web.xml') do
    it { should exist }
    it { should be_file }
    its('owner') { should eq 'tomcat' }
    its('group') { should eq 'tomcat' }
    its('mode') { should cmp '0640' }
  end
  describe file('/usr/share/tomcat/conf/context.xml') do
    it { should exist }
    it { should be_file }
    its('owner') { should eq 'tomcat' }
    its('group') { should eq 'tomcat' }
    its('mode') { should cmp '0640' }
  end
  describe file('/usr/share/tomcat/conf/server.xml') do
    it { should exist }
    it { should be_file }
    its('owner') { should eq 'tomcat' }
    its('group') { should eq 'tomcat' }
    its('mode') { should cmp '0640' }
  end
end
