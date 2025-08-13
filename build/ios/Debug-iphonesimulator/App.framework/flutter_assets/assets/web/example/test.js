function testEcho() {
    if (window.flutter_invoke) {
      window.flutter_invoke('echo', {msg: 'hello from js'}).then(res => {
        alert('原生返回: ' + JSON.stringify(res));
      });
    } else {
      alert('flutter_invoke 不存在');
    }
  }
  function testAppid() {
    plus.runtime.appid.then(appid => alert('appid: ' + appid));
  }
  function testVersion() {
    plus.runtime.version.then(version => alert('version: ' + version));
  }
  function testGetProperty() {
    plus.runtime.getProperty('com.example.flutter_base', function(info) {
      alert('getProperty: ' + JSON.stringify(info));
    });
  }
  function testQuit() {
    plus.runtime.quit();
  }