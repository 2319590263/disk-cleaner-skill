// 测试OpenClaw浏览器功能
const { execSync } = require('child_process');
const fs = require('fs');

console.log('测试浏览器功能...');

// 检查OpenClaw浏览器插件
try {
  const result = execSync('openclaw plugins list --json', { encoding: 'utf8' });
  const plugins = JSON.parse(result);
  const browserPlugin = plugins.find(p => p.id === 'browser');
  
  if (browserPlugin && browserPlugin.status === 'loaded') {
    console.log('✅ 浏览器插件已加载:', browserPlugin.name);
  } else {
    console.log('❌ 浏览器插件未加载');
  }
} catch (error) {
  console.log('❌ 检查插件时出错:', error.message);
}

// 检查agent-browser CLI
try {
  execSync('agent-browser --help', { encoding: 'utf8' });
  console.log('✅ agent-browser CLI已安装');
} catch (error) {
  console.log('❌ agent-browser CLI未完全安装:', error.message);
}

console.log('\n建议:');
console.log('1. 如果agent-browser下载Chrome失败，可以手动下载Chrome');
console.log('2. 或者使用OpenClaw内置的浏览器工具');
console.log('3. 也可以考虑安装其他浏览器自动化工具如puppeteer');