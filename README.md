metadash
========

A meta-dashboard for aggregating other dashboards, currently to merge multiple sensu servers into a single dashboard.

Here's a sample screenshot, but be warned, much of the functionality is incomplete (i.e. the entire top navbar)

![ScreenShot](https://dl.dropboxusercontent.com/u/39033486/metadash-screenshot.png)
![ScreenShot](https://dl.dropboxusercontent.com/u/39033486/metadash-clients.png)


setup
=====

Create config.js in the root directory. For better or worse, this is currently an exported js object.

    (function(exports){

        'use strict';
        exports.servers = [
            {
                slug: 'name1',
                host: 'sensu1.example.com',
            },
            {
                slug: 'name2',
                host: 'sensu2.example.com',
            }
        ];

        exports.links = {
            events : [
                {
                    label: 'Urgent',
                    query: '?status=2|3&silenced=0'
                },
                {
                    label: 'Silenced',
                    query: '?silenced=1'
                },
                {
                     label: 'You\'ve been warned.',
                     query: '?status=1'
                },
                {
                    label: 'Everything',
                    query: ''
                }
            ],
            clients : [
                {
                    label: 'Load Balancers',
                    query: '?filter=load_balancers'
                },
                {
                    label: 'Frontends',
                    query: '?filter=frontend'
                },
                {
                     label: 'DB Servers',
                     query: '?filter=postgres|cassandra'
                },
                {
                    label: 'Everything',
                    query: ''
                }
            ]            
        }

    })(typeof exports === 'undefined'? this.sensu={}: exports);

Test the config with grunt dev server:

    npm install grunt-cli -g
    npm install bower -g
    npm install
    bower install
    grunt server
    
Or to build a production release to the dist folder:

    grunt build

Build scripts and artifacts are readily available on cloudbees: https://socrata-oss.ci.cloudbees.com/job/metadash/

For production, drop the config.js into the dist directory, 
and configure a webserver to serve it statically and proxy api requests to sensu-api.
Here's an example nginx config:

    proxy_cache_path /var/cache/nginx levels=2 keys_zone=SENSU:8m
                                  max_size=100m inactive=5m;
    server {
      listen 80;
      proxy_cache SENSU;
      proxy_cache_valid 200 302 20s;
      proxy_cache_valid 404 10s;
      location /name1/ {
         proxy_pass http://sensu1.example.com:4567 %>/;
      }
      location /name2/ {
         proxy_pass http://sensu2.example.com:4567 %>/;
      }
      location / {
        root /path/to/metadash/dist;
        try_files $uri /index.html;
      }
    }

