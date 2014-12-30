class WebHookService

  def process_webhook(webhook)
    LOGGER.info "Processing webhook:#{webhook.id}; uri:#{webhook.uri}"
  end
end