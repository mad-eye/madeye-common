{assert} = require 'chai'
{crc32} = require '../../src/crc32'

describe 'CRC32', ->
  it 'should give different results for different strings', ->
    assert.notEqual crc32('a cat is growing in the shade'), crc32('a dog is growing in the shade')

  it 'should give different results for strings differing by a transposition', ->
    assert.notEqual crc32('a cat is growing in the shade'), crc32('a cati s growing in the shade')

  it 'should give different results for strings differing by a capitalization', ->
    assert.notEqual crc32('a cat is growing in the shade'), crc32('a caT is growing in the shade')

  it 'should give same result for equal strings', ->
    assert.equal crc32('a cat is growing in the shade'), crc32('a cat is growing in the shade')

  it 'should ignore linbreak differences', ->
    original = 'a cat was\n in the \r\nfountain, but sadly\r swam.'
    replaced = original.replace(/\r\n|\r|\n/gm, '\n')
    assert.equal crc32(replaced), crc32(original)

