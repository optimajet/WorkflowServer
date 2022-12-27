import Vue from 'vue';

import jQuery from 'jquery';
window.$ = jQuery;

import ElementUI from 'element-ui';

import * as Oidc from 'oidc-client';
window.Oidc = Oidc;

import './scripts/silent-renew';

import WorkflowServer from './src/WorkflowServer'
window.WorkflowServer = WorkflowServer;

import './css/style.css';

Vue.use(ElementUI);
