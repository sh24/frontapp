module Frontapp
  class Client
    module Drafts

      #
      # Parameters
      # Name        Type    Description
      # -------------------------------
      # channel_id  string  Id or address of the channel from which to send the message
      # -------------------------------
      #
      # Allowed attributes:
      # Name             Type                Description
      # ------------------------------------------------
      # author_id        string              Id of the teammate on behalf of whom the answer is sent
      # sender_name      string (optional)   Name used for the sender info of the message
      # subject          string (optional)   Subject of the message for email message
      # body             string              Body of the message
      # quote_body       string (optional)
      # text             string (optional)   Text version of the body for messages with non-text body
      # attachments      array (optional)    Binary data of the attached files. Available only for multipart request.
      # options          object (optional)   Sending options
      # options.tags     array (optional)    List of tag names to add to the conversation (unknown tags will automatically be created)
      # options.archive  boolean (optional)  Archive the conversation right when sending the reply (Default: true)
      # to               array (optional)    List of the recipient handles who will receive this message
      # cc               array (optional)    List of the recipient handles who will receive a copy of this message
      # bcc              array (optional)    List of the recipient handles who will receive a blind copy of this message
      # mode             string (optional)   private|shared, default: private
      # signature_id
      # should_add_default_signature
      # ------------------------------------------------
      def create_draft(channel_id, params)
        cleaned = params.permit(:author_id,
                                :sender_name,
                                :subject,
                                :body,
                                :quote_body,
                                :text,
                                :attachments,
                                { options: [:tags, :archive] },
                                :to,
                                :cc,
                                :bcc,
                                :mode,
                                :signature_id,
                                :should_add_default_signature)
        create("channels/#{channel_id}/drafts", cleaned)
      end
    end
  end
end
