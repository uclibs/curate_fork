require 'spec_helper'

describe 'generic files routing' do
  let(:parent_id) { '1a2b3c' }
  let(:child_id) { '1a2b3c4d5e' }

  it "routes GET /works/related_files/:id" do
    expect(
      get: "/works/files/#{child_id}"
    ).to(
      route_to(
        controller: "curation_concern/generic_files",
        action: "show",
        id: child_id
      )
    )
  end

  it "routes GET /works/related_files/:id/edit" do
    expect(
      get: "/works/files/#{child_id}/edit"
    ).to(
      route_to(
        controller: "curation_concern/generic_files",
        action: "edit",
        id: child_id
      )
    )
  end

  it "routes GET /works/related_files/:id" do
    expect(
      put: "/works/files/#{child_id}"
    ).to(
      route_to(
        controller: "curation_concern/generic_files",
        action: "update",
        id: child_id
      )
    )
  end

  it "routes GET /works/container/:parent_id/related_files/new" do
    expect(
      get: "/works/container/#{parent_id}/files/new"
    ).to(
      route_to(
        controller: "curation_concern/generic_files",
        action: "new",
        parent_id: parent_id
      )
    )
  end

  it "routes POST /works/container/:parent_id/related_files" do
    expect(
      post: "/works/container/#{parent_id}/files"
    ).to(
      route_to(
        controller: "curation_concern/generic_files",
        action: "create",
        parent_id: parent_id
      )
    )
  end

  it "routes DELETE /works/container/:parent_id/related_files" do
    expect(
      delete: "/works/files/#{child_id}"
    ).to(
      route_to(
        controller: "curation_concern/generic_files",
        action: "destroy",
        id: child_id
      )
    )
  end

end
