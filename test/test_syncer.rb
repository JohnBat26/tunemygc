# encoding: utf-8

require File.join(File.dirname(__FILE__), 'helper')

class TestSyncer < TuneMyGcTestCase
  def test_uri
    syncer = TuneMyGc::Syncer.new
    assert_equal "tunemygc.com", syncer.uri.host
    assert_equal 443, syncer.uri.port
  end

  def test_client
    syncer = TuneMyGc::Syncer.new
    assert_instance_of Net::HTTP, syncer.client
  end

  def test_environment
    assert_equal 7, TuneMyGc::Syncer::ENVIRONMENT.size
  end

  def test_sync_valid_snapshot
    syncer = TuneMyGc::Syncer.new
    snapshots = TuneMyGc::Snapshotter.new
    snapshots.take_raw(Fixtures::STAGE_READY)
    stub_request(:post, "https://tunemygc.com/ruby").
      with(:body => "[#{ActiveSupport::JSON.encode(TuneMyGc::Syncer::ENVIRONMENT)},[1420152606.1162581,\"READY\",{\"count\":32,\"heap_used\":950,\"heap_length\":1519,\"heap_increment\":569,\"heap_live_slot\":385225,\"heap_free_slot\":2014,\"heap_final_slot\":0,\"heap_swept_slot\":101119,\"heap_eden_page_length\":950,\"heap_tomb_page_length\":0,\"total_allocated_object\":2184137,\"total_freed_object\":1798912,\"malloc_increase\":9665288,\"malloc_limit\":16777216,\"minor_gc_count\":26,\"major_gc_count\":6,\"remembered_shady_object\":5145,\"remembered_shady_object_limit\":6032,\"old_object\":230164,\"old_object_limit\":301030,\"oldmalloc_increase\":11715304,\"oldmalloc_limit\":24159190},{\"major_by\":null,\"gc_by\":\"newobj\",\"have_finalizer\":false,\"immediate_sweep\":false},null]]",
           :headers => {'Accept'=>'application/json', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Content-Type'=>'application/json', 'User-Agent'=>'TuneMyGC 1.0'}).
      to_return(:status => 200, :body => "", :headers => {})

    out, err = capture_io do
      assert_equal false, syncer.sync(snapshots)
    end
    assert_match(/Syncing 1 snapshots/, out)
  end

  def test_not_supported
    syncer = TuneMyGc::Syncer.new
    snapshots = TuneMyGc::Snapshotter.new
    snapshots.take_raw(Fixtures::STAGE_READY)
    stub_request(:post, "https://tunemygc.com/ruby").
      with(:body => "[#{ActiveSupport::JSON.encode(TuneMyGc::Syncer::ENVIRONMENT)},[1420152606.1162581,\"READY\",{\"count\":32,\"heap_used\":950,\"heap_length\":1519,\"heap_increment\":569,\"heap_live_slot\":385225,\"heap_free_slot\":2014,\"heap_final_slot\":0,\"heap_swept_slot\":101119,\"heap_eden_page_length\":950,\"heap_tomb_page_length\":0,\"total_allocated_object\":2184137,\"total_freed_object\":1798912,\"malloc_increase\":9665288,\"malloc_limit\":16777216,\"minor_gc_count\":26,\"major_gc_count\":6,\"remembered_shady_object\":5145,\"remembered_shady_object_limit\":6032,\"old_object\":230164,\"old_object_limit\":301030,\"oldmalloc_increase\":11715304,\"oldmalloc_limit\":24159190},{\"major_by\":null,\"gc_by\":\"newobj\",\"have_finalizer\":false,\"immediate_sweep\":false},null]]",
           :headers => {'Accept'=>'application/json', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Content-Type'=>'application/json', 'User-Agent'=>'TuneMyGC 1.0'}).
      to_return(:status => 501, :body => "", :headers => {})

    out, err = capture_io do
      assert_nil syncer.sync(snapshots)
    end
    assert_match(/Ruby version/, out)
    assert_match(/Rails version/, out)
    assert_match(/not supported/, out)
    assert_match(/Failed to sync 1 snapshots/, out)
  end

  def test_already_configured
    syncer = TuneMyGc::Syncer.new
    snapshots = TuneMyGc::Snapshotter.new
    snapshots.take_raw(Fixtures::STAGE_READY)
    stub_request(:post, "https://tunemygc.com/ruby").
      with(:body => "[#{ActiveSupport::JSON.encode(TuneMyGc::Syncer::ENVIRONMENT)},[1420152606.1162581,\"READY\",{\"count\":32,\"heap_used\":950,\"heap_length\":1519,\"heap_increment\":569,\"heap_live_slot\":385225,\"heap_free_slot\":2014,\"heap_final_slot\":0,\"heap_swept_slot\":101119,\"heap_eden_page_length\":950,\"heap_tomb_page_length\":0,\"total_allocated_object\":2184137,\"total_freed_object\":1798912,\"malloc_increase\":9665288,\"malloc_limit\":16777216,\"minor_gc_count\":26,\"major_gc_count\":6,\"remembered_shady_object\":5145,\"remembered_shady_object_limit\":6032,\"old_object\":230164,\"old_object_limit\":301030,\"oldmalloc_increase\":11715304,\"oldmalloc_limit\":24159190},{\"major_by\":null,\"gc_by\":\"newobj\",\"have_finalizer\":false,\"immediate_sweep\":false},null]]",
           :headers => {'Accept'=>'application/json', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Content-Type'=>'application/json', 'User-Agent'=>'TuneMyGC 1.0'}).
      to_return(:status => 412, :body => "", :headers => {})

    out, err = capture_io do
      assert_nil syncer.sync(snapshots)
    end
    assert_match(/The GC is already tuned by environment variables/, out)
    assert_match(/Failed to sync 1 snapshots/, out)
  end

  def test_bad_payload
    syncer = TuneMyGc::Syncer.new
    snapshots = TuneMyGc::Snapshotter.new
    snapshots.take_raw(Fixtures::STAGE_READY)
    stub_request(:post, "https://tunemygc.com/ruby").
      with(:body => "[#{ActiveSupport::JSON.encode(TuneMyGc::Syncer::ENVIRONMENT)},[1420152606.1162581,\"READY\",{\"count\":32,\"heap_used\":950,\"heap_length\":1519,\"heap_increment\":569,\"heap_live_slot\":385225,\"heap_free_slot\":2014,\"heap_final_slot\":0,\"heap_swept_slot\":101119,\"heap_eden_page_length\":950,\"heap_tomb_page_length\":0,\"total_allocated_object\":2184137,\"total_freed_object\":1798912,\"malloc_increase\":9665288,\"malloc_limit\":16777216,\"minor_gc_count\":26,\"major_gc_count\":6,\"remembered_shady_object\":5145,\"remembered_shady_object_limit\":6032,\"old_object\":230164,\"old_object_limit\":301030,\"oldmalloc_increase\":11715304,\"oldmalloc_limit\":24159190},{\"major_by\":null,\"gc_by\":\"newobj\",\"have_finalizer\":false,\"immediate_sweep\":false},null]]",
           :headers => {'Accept'=>'application/json', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Content-Type'=>'application/json', 'User-Agent'=>'TuneMyGC 1.0'}).
      to_return(:status => 400, :body => "snapshot timestamp", :headers => {})

    out, err = capture_io do
      assert_nil syncer.sync(snapshots)
    end
    assert_match(/Invalid payload/, out)
    assert_match(/snapshot timestamp/, out)
    assert_match(/Failed to sync 1 snapshots/, out)
  end

  def test_upgrade_required
    syncer = TuneMyGc::Syncer.new
    snapshots = TuneMyGc::Snapshotter.new
    snapshots.take_raw(Fixtures::STAGE_READY)
    stub_request(:post, "https://tunemygc.com/ruby").
      with(:body => "[#{ActiveSupport::JSON.encode(TuneMyGc::Syncer::ENVIRONMENT)},[1420152606.1162581,\"READY\",{\"count\":32,\"heap_used\":950,\"heap_length\":1519,\"heap_increment\":569,\"heap_live_slot\":385225,\"heap_free_slot\":2014,\"heap_final_slot\":0,\"heap_swept_slot\":101119,\"heap_eden_page_length\":950,\"heap_tomb_page_length\":0,\"total_allocated_object\":2184137,\"total_freed_object\":1798912,\"malloc_increase\":9665288,\"malloc_limit\":16777216,\"minor_gc_count\":26,\"major_gc_count\":6,\"remembered_shady_object\":5145,\"remembered_shady_object_limit\":6032,\"old_object\":230164,\"old_object_limit\":301030,\"oldmalloc_increase\":11715304,\"oldmalloc_limit\":24159190},{\"major_by\":null,\"gc_by\":\"newobj\",\"have_finalizer\":false,\"immediate_sweep\":false},null]]",
           :headers => {'Accept'=>'application/json', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Content-Type'=>'application/json', 'User-Agent'=>'TuneMyGC 1.0'}).
      to_return(:status => 426, :body => "2", :headers => {})

    out, err = capture_io do
      assert_nil syncer.sync(snapshots)
    end
    assert_match(/Agent version 2 required/, out)
    assert_match(/Failed to sync 1 snapshots/, out)
  end

  def test_sync_error
    syncer = TuneMyGc::Syncer.new
    snapshots = TuneMyGc::Snapshotter.new
    snapshots.take_raw(Fixtures::STAGE_READY)
    stub_request(:post, "https://tunemygc.com/ruby").
      with(:body => "[#{ActiveSupport::JSON.encode(TuneMyGc::Syncer::ENVIRONMENT)},[1420152606.1162581,\"READY\",{\"count\":32,\"heap_used\":950,\"heap_length\":1519,\"heap_increment\":569,\"heap_live_slot\":385225,\"heap_free_slot\":2014,\"heap_final_slot\":0,\"heap_swept_slot\":101119,\"heap_eden_page_length\":950,\"heap_tomb_page_length\":0,\"total_allocated_object\":2184137,\"total_freed_object\":1798912,\"malloc_increase\":9665288,\"malloc_limit\":16777216,\"minor_gc_count\":26,\"major_gc_count\":6,\"remembered_shady_object\":5145,\"remembered_shady_object_limit\":6032,\"old_object\":230164,\"old_object_limit\":301030,\"oldmalloc_increase\":11715304,\"oldmalloc_limit\":24159190},{\"major_by\":null,\"gc_by\":\"newobj\",\"have_finalizer\":false,\"immediate_sweep\":false},null]]",
           :headers => {'Accept'=>'application/json', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Content-Type'=>'application/json', 'User-Agent'=>'TuneMyGC 1.0'}).to_raise(IOError.new("dang"))

    out, err = capture_io do
      assert_nil syncer.sync(snapshots)
    end
    assert_match(/Failed to sync 1 snapshots/, out)
    assert_match(/dang/, out)
  end
end