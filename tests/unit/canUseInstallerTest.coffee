{assert} = require 'chai'
{canUseInstaller} = require '../../common'

describe 'canUseInstaller', ->
  it 'should return true for darwin x64', ->
    assert.ok canUseInstaller {platform:'darwin', arch:'x64'}
  it 'should return true for linux x64', ->
    assert.ok canUseInstaller {platform:'linux', arch:'x64'}
  it 'should return true for linux ia32', ->
    assert.ok canUseInstaller {platform:'linux', arch:'ia32'}
  it 'should return false for sunos x64', ->
    assert.ok !canUseInstaller {platform:'sunos', arch:'x64'}
  it 'should return false for sunos ia32', ->
    assert.ok !canUseInstaller {platform:'sunos', arch:'ia32'}
  it 'should return false for windows', ->
    assert.ok !canUseInstaller {platform:'windows', arch:'x64'}

