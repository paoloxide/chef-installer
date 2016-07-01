server_name = "localhost"
api_fqdn server_name
bookshelf['vip'] = server_name
nginx['url'] = "http://#{server_name}"
nginx['server_name'] = server_name
nginx['ssl_certificate'] = "/var/opt/opscode/nginx/ca/#{server_name}.crt"
nginx['ssl_certificate_key'] = "/var/opt/opscode/nginx/ca/#{server_name}.key"
ldap['host'] = '52.208.18.30'
ldap['port'] = '389'
ldap['bind_dn'] = 'cn=admin,dc=ldap,dc=example,dc=com'
ldap['bind_password'] = 'Jpk66g63ZifGYIcShSGM'
ldap['base_dn'] = 'ou=people,dc=ldap,dc=example,dc=com'
ldap['group_dn'] = 'cn=administrators,ou=groups,dc=ldap,dc=example,dc=com'