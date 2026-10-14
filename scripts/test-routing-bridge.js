// Validate the actual bridge source embedded in Objective-C without a WebView.
const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');
const vm = require('node:vm');
const { spawnSync } = require('node:child_process');

const source = fs.readFileSync(path.join(__dirname, '../Modules/Hybrid/GrowingWKWebViewJavascriptBridge_JS.m'), 'utf8');
const start = source.indexOf('(function()');
const end = source.indexOf('})(););', start);
assert.ok(start >= 0 && end > start, 'Embedded bridge source must be present');
const initial = { dataSourceId: 'A', sessionId: 'A-1', sequence: 0 };
const messages = [];
const changes = [];
const window = {
  webkit: { messageHandlers: { GrowingWKWebViewJavascriptBridge: {
    postMessage(message) { messages.push(JSON.parse(message)); },
  } } },
  dispatchEvent(event) { changes.push(event.detail); },
};
const document = {
  createEvent() { return { initCustomEvent(type, bubbles, cancelable, detail) { this.detail = detail; } }; },
};
const preprocessing = spawnSync('clang', ['-E', '-P', '-x', 'c', '-'], {
  input: '#define GROWING_JS(x) #x\nconst char *gioRoutingTestBridge = GROWING_JS(' + source.slice(start, end + 5) + ');',
  encoding: 'utf8',
});
assert.equal(preprocessing.status, 0, preprocessing.stderr);
const literal = preprocessing.stdout.match(/gioRoutingTestBridge\s*=\s*("(?:\\.|[^"\\])*")\s*;/);
assert.ok(literal, 'The C preprocessor must produce the bridge string');
const javascript = JSON.parse(literal[1]).replace('$configuration_replacement',
  JSON.stringify({ dataSourceId: 'A', routingContext: initial }));
vm.runInNewContext(javascript, { window, document, setTimeout, clearTimeout, console });
const bridge = window.GrowingWebViewJavascriptBridge;
const b = { dataSourceId: 'B', sessionId: 'B-1', sequence: 1 };
bridge._updateRoutingContext(b);
assert.deepEqual(changes, [b]);
bridge.dispatchEvent(JSON.stringify({ eventType: 'CUSTOM' }));
assert.deepEqual(JSON.parse(messages.at(-1).data).routingContext, initial, 'Unconfirmed events keep the old context');
assert.equal(bridge.confirmRoutingContext(initial), false);
assert.equal(bridge.confirmRoutingContext(b), true);
bridge.dispatchEvent(JSON.stringify({ eventType: 'CUSTOM', routingContext: initial }));
assert.deepEqual(JSON.parse(messages.at(-1).data).routingContext, initial, 'Buffered events keep their creation context');
bridge.dispatchEvent(JSON.stringify({ eventType: 'CUSTOM' }));
assert.deepEqual(JSON.parse(messages.at(-1).data).routingContext, b);

const a2 = { dataSourceId: 'A', sessionId: 'A-2', sequence: 2 };
bridge._updateRoutingContext(a2);
assert.equal(bridge.confirmRoutingContext(b), false, 'A stale acknowledgement cannot replace a newer update');
assert.equal(bridge.confirmRoutingContext(a2), true);
assert.equal(bridge.getRoutingContext().sessionId, 'A-2');

const a3 = { dataSourceId: 'A', sessionId: 'A-3', sequence: 2 };
bridge._updateRoutingContext(a3);
assert.equal(bridge.confirmRoutingContext(a3), true, 'Ordinary session refreshes can keep the routing sequence');
assert.equal(bridge.getRoutingContext().sessionId, 'A-3');
bridge._updateRoutingContext(b);
assert.equal(bridge.getRoutingContext().sessionId, 'A-3', 'An older routing generation cannot replace current context');
console.log('Routing bridge protocol checks passed');
