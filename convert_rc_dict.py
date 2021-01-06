import json 
import sys

with open(sys.argv[1]) as fh:
    rc_lines = fh.readlines()

env_vars = {'cacert':  "", 'auth_vars': {}} 
for line in rc_lines:
    if not line.startswith('#') and 'export' in line and 'OS_' in line:
         var_line = line.lower().strip().split(' ')[1].split('=')
         param = var_line[0][3:]
         if param == 'auth_url' or param == 'username' or param == 'password' or param == 'project_name' or param == 'user_domain_name' or param == 'project_domain_name':
              env_vars['auth_vars'][param] = var_line[1]
         elif  param == 'cacert':
             env_vars['cacert'] = var_line[1]
print(json.dumps(env_vars))
