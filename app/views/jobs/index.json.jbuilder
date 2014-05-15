json.array!(@jobs) do |job|
  json.extract! job, :id, :reference_file, :md5sum, :operation, :storage_type, :aasm_state
  json.url job_url(job, format: :json)
end
