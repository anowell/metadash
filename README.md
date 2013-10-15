metadash
========

A meta-dashboard for aggregating other dashboards, currently to merge multiple sensu servers into a single dashboard


setup
=====

Create sensu-config.js in the root directory. Eventually, this will be a saner config file,
but for now it's an exported js object.

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
            ]
        }

    })(typeof exports === 'undefined'? this.sensu={}: exports);

Then you can kick of the grunt dev server:

    grunt server
    
Soon, I'll fix proxy.js to forward needed routes to backbone so that we can run this in production:

    grunt build
    node proxy.js # but this doesn't forward the needed routes to backbone, yet
    
