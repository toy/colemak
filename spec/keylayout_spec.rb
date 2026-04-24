require 'rspec'
require 'keylayout'

describe Keylayout do
  Dir['keylayouts/**/*.keylayout'].each do |path|
    context "for #{path}" do
      let(:data){ File.read(path).gsub('&#x0;', '&#x10;') }
      let(:reformatted) do
        doc = Nokogiri::XML(data)
        doc.xpath('//comment()').remove
        doc.to_xml.gsub("\t", '  ')
      end
      let(:regenerated){ Keylayout.parse(data).to_xml(gap_comments: false, reset_ids: false) }

      it 'keeps XML as is' do
        expect(regenerated).to eq(reformatted)
      end
    end
  end

  describe 'adding gap comments' do
    let(:keylayout) do
      Keylayout.parse(<<~XML)
        <?xml version="1.0" encoding="UTF-8"?>
        <!DOCTYPE keyboard SYSTEM "file://localhost/System/Library/DTDs/KeyboardLayout.dtd">
        <keyboard group="126" id="-12825" name="Colemak" maxout="1">
          <layouts>
            <layout first="0" last="0" modifiers="0" mapSet="0"/>
          </layouts>
          <modifierMap id="0" defaultIndex="0">
            <keyMapSelect mapIndex="0">
              <modifier keys=""/>
            </keyMapSelect>
            <keyMapSelect mapIndex="1">
              <modifier keys="anyShift"/>
            </keyMapSelect>
            <keyMapSelect mapIndex="2">
              <modifier keys="caps anyShift?"/>
            </keyMapSelect>
          </modifierMap>
          <keyMapSet id="0">
            <keyMap index="0">
              <key code="0" output="a"/>
              <key code="1" output="b"/>
              <key code="2" output="c"/>
              <key code="4" output="d"/>
              <key code="10" output="e"/>
            </keyMap>
            <keyMap index="1">
              <key code="1" output="b"/>
              <key code="2" output="c"/>
              <key code="4" output="d"/>
              <key code="10" output="e"/>
            </keyMap>
            <keyMap index="2">
              <key code="2" output="c"/>
              <key code="4" output="d"/>
              <key code="10" output="e"/>
            </keyMap>
          </keyMapSet>
        </keyboard>
      XML
    end

    it 'adds gap comments' do
      expect(keylayout.to_xml(gap_comments: true)).to eq <<~XML
        <?xml version="1.0" encoding="UTF-8"?>
        <!DOCTYPE keyboard SYSTEM "file://localhost/System/Library/DTDs/KeyboardLayout.dtd">
        <keyboard group="126" id="-12825" name="Colemak" maxout="1">
          <layouts>
            <layout first="0" last="0" modifiers="0" mapSet="0"/>
          </layouts>
          <modifierMap id="0" defaultIndex="0">
            <keyMapSelect mapIndex="0">
              <modifier keys=""/>
            </keyMapSelect>
            <keyMapSelect mapIndex="1">
              <modifier keys="anyShift"/>
            </keyMapSelect>
            <keyMapSelect mapIndex="2">
              <modifier keys="caps anyShift?"/>
            </keyMapSelect>
          </modifierMap>
          <keyMapSet id="0">
            <keyMap index="0">
              <key code="0" output="a"/>
              <key code="1" output="b"/>
              <key code="2" output="c"/>
              <!-- gap 3 -->
              <key code="4" output="d"/>
              <!-- gap 5..9 -->
              <key code="10" output="e"/>
            </keyMap>
            <keyMap index="1">
              <!-- gap 0 -->
              <key code="1" output="b"/>
              <key code="2" output="c"/>
              <!-- gap 3 -->
              <key code="4" output="d"/>
              <!-- gap 5..9 -->
              <key code="10" output="e"/>
            </keyMap>
            <keyMap index="2">
              <!-- gap 0..1 -->
              <key code="2" output="c"/>
              <!-- gap 3 -->
              <key code="4" output="d"/>
              <!-- gap 5..9 -->
              <key code="10" output="e"/>
            </keyMap>
          </keyMapSet>
        </keyboard>
      XML
    end
  end
end
