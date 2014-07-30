defmodule Hedwig.XMLNS do
  defmacro __using__([]) do
    quote do
      import unquote __MODULE__
    end
  end

  # Defined by XML.
  def ns_xml, do: "http://www.w3.org/XML/1998/namespace"

  # Defined by XMPP Core  RFC 3920).
  def ns_xmpp, do: "http://etherx.jabber.org/streams"

  def ns_stream_errors, do: "urn:ietf:params:xml:ns:xmpp-streams"
  def ns_tls, do: "urn:ietf:params:xml:ns:xmpp-tls"
  def ns_sasl, do: "urn:ietf:params:xml:ns:xmpp-sasl"
  def ns_bind, do: "urn:ietf:params:xml:ns:xmpp-bind"
  def ns_stanza_errors, do: "urn:ietf:params:xml:ns:xmpp-stanzas"

  # Defined by XMPP-IM  RFC 3921).
  def ns_jabber_client, do: "jabber:client"

  def ns_jabber_server, do: "jabber:server"

  def ns_session, do: "urn:ietf:params:xml:ns:xmpp-session"

  def ns_roster, do: "jabber:iq:roster"

  # Defined by End-to-End Signing and Object Encryption for XMPP  RFC 3923).
  def ns_e2e, do: "urn:ietf:params:xml:ns:xmpp-e2e"

  # Defined by XEP-0003: Proxy Accept Socket Service  PASS).
  def ns_pass, do: "jabber:iq:pass"

  # Defined by XEP-0004: Data Forms.
  def ns_data_forms, do: "jabber:x:data"

  # Defined by XEP-0009: Jabber-RPC.
  def ns_rpc, do: "jabber:iq:rpc"

  # Defined by XEP-0011: Jabber Browsing.
  def ns_browse, do: "jabber:iq:browse"

  # Defined by XEP-0012: Last Activity.
  def ns_last_activity, do: "jabber:iq:last"

  # Defined by XEP-0013: Flexible Offline Message Retrieval.
  def ns_offline, do: "http://jabber.org/protocol/offline"

  # Defined by XEP-0016: Privacy Lists.
  def ns_privacy, do: "jabber:iq:privacy"

  # Defined by XEP-0020: Feature Negotiation.
  def ns_feature_neg, do: "http://jabber.org/protocol/feature-neg"

  # Defined by XEP-0022: Message Events.
  def ns_message_event, do: "jabber:x:event"

  # Defined by XEP-0023: Message Expiration.
  def ns_message_expire, do: "jabber:x:expire"

  # Defined by XEP-0027: Current Jabber OpenPGP Usage.
  def ns_pgp_encrypted, do: "jabber:x:encrypted"
  def ns_pgp_signed, do: "jabber:x:signed"

  # Defined by XEP-0030: Service Discovery.
  def ns_disco_info, do: "http://jabber.org/protocol/disco#info"
  def ns_disco_items, do: "http://jabber.org/protocol/disco#items"

  # Defined by XEP-0033: Extended Stanza Addressing.
  def ns_address, do: "http://jabber.org/protocol/address"

  # Defined by XEP-0039: Statistics Gathering.
  def ns_stats, do: "http://jabber.org/protocol/stats"

  # Defined by XEP-0045: Multi-User Chat.
  def ns_muc, do: "http://jabber.org/protocol/muc"
  def ns_muc_admin, do: "http://jabber.org/protocol/muc#admin"
  def ns_muc_owner, do: "http://jabber.org/protocol/muc#owner"
  def ns_muc_unique, do: "http://jabber.org/protocol/muc#unique"
  def ns_muc_user, do: "http://jabber.org/protocol/muc#user"

  # Defined by XEP-0047: In-Band Bytestreams.
  def ns_ibb, do: "http://jabber.org/protocol/ibb"

  # Defined by XEP-0048: Bookmarks.
  def ns_bookmarks, do: "storage:bookmarks"

  # Defined by XEP-0049: Private XML Storage.
  def ns_private, do: "jabber:iq:private"

  # Defined by XEP-0050: Ad-Hoc Commands.
  def ns_adhoc, do: "http://jabber.org/protocol/commands"

  # Defined by XEP-0054: vcard-temp.
  def ns_vcard, do: "vcard-temp"

  # Defined by XEP-0055: Jabber Search.
  def ns_search, do: "jabber:iq:search"

  # Defined by XEP-0059: Result Set Management.
  def ns_rsm, do: "http://jabber.org/protocol/rsm"

  # Defined by XEP-0060: Publish-Subscribe.
  def ns_pubsub, do: "http://jabber.org/protocol/pubsub"
  def ns_pubsub_errors, do: "http://jabber.org/protocol/pubsub#errors"
  def ns_pubsub_event, do: "http://jabber.org/protocol/pubsub#event"
  def ns_pubsub_owner, do: "http://jabber.org/protocol/pubsub#owner"
  def ns_pubsub_subscribe_auth, do: "http://jabber.org/protocol/pubsub#subscribe_authorization"
  def ns_pubsub_subscribe_options, do: "http://jabber.org/protocol/pubsub#subscribe_options"
  def ns_pubsub_node_config, do: "http://jabber.org/protocol/pubsub#node_config"

  def ns_pubsub_access_auth, do: "http://jabber.org/protocol/pubsub#access-authorize"
  def ns_pubsub_access_open, do: "http://jabber.org/protocol/pubsub#access-open"
  def ns_pubsub_access_presence, do: "http://jabber.org/protocol/pubsub#access-presence"
  def ns_pubsub_access_roster, do: "http://jabber.org/protocol/pubsub#access-roster"
  def ns_pubsub_access_whitelist, do: "http://jabber.org/protocol/pubsub#access-whitelist"
  def ns_pubsub_auto_create, do: "http://jabber.org/protocol/pubsub#auto-create"
  def ns_pubsub_auto_subscribe, do: "http://jabber.org/protocol/pubsub#auto-subscribe"
  def ns_pubsub_collections, do: "http://jabber.org/protocol/pubsub#collections"
  def ns_pubsub_config_node, do: "http://jabber.org/protocol/pubsub#config-node"
  def ns_pubsub_create_configure, do: "http://jabber.org/protocol/pubsub#create-and-configure"
  def ns_pubsub_create_nodes, do: "http://jabber.org/protocol/pubsub#create-nodes"
  def ns_pubsub_delete_items, do: "http://jabber.org/protocol/pubsub#delete-items"
  def ns_pubsub_delete_nodes, do: "http://jabber.org/protocol/pubsub#delete-nodes"
  def ns_pubsub_filtered_notifications, do: "http://jabber.org/protocol/pubsub#filtered-notifications"
  def ns_pubsub_get_pending, do: "http://jabber.org/protocol/pubsub#get-pending"
  def ns_pubsub_instant_nodes, do: "http://jabber.org/protocol/pubsub#instant-nodes"
  def ns_pubsub_item_ids, do: "http://jabber.org/protocol/pubsub#item-ids"
  def ns_pubsub_last_published, do: "http://jabber.org/protocol/pubsub#last-published"
  def ns_pubsub_leased_subscription, do: "http://jabber.org/protocol/pubsub#leased-subscription"
  def ns_pubsub_manage_subscriptions, do: "http://jabber.org/protocol/pubsub#manage-subscriptions"
  def ns_pubsub_member_affiliation, do: "http://jabber.org/protocol/pubsub#member-affiliation"
  def ns_pubsub_meta_data, do: "http://jabber.org/protocol/pubsub#meta-data"
  def ns_pubsub_modify_affiliations, do: "http://jabber.org/protocol/pubsub#modify-affiliations"
  def ns_pubsub_multi_collection, do: "http://jabber.org/protocol/pubsub#multi-collection"
  def ns_pubsub_multi_subscribe, do: "http://jabber.org/protocol/pubsub#multi-subscribe"
  def ns_pubsub_outcast_affiliation, do: "http://jabber.org/protocol/pubsub#outcast-affiliation"
  def ns_pubsub_persistent_items, do: "http://jabber.org/protocol/pubsub#persistent-items"
  def ns_pubsub_presence_notifications, do: "http://jabber.org/protocol/pubsub#presence-notifications"
  def ns_pubsub_presence_subscribe, do: "http://jabber.org/protocol/pubsub#presence-subscribe"
  def ns_pubsub_publish, do: "http://jabber.org/protocol/pubsub#publish"
  def ns_pubsub_publish_options, do: "http://jabber.org/protocol/pubsub#publish-options"
  def ns_pubsub_publish_only_affiliation, do: "http://jabber.org/protocol/pubsub#publish-only-affiliation"
  def ns_pubsub_publisher_affiliation, do: "http://jabber.org/protocol/pubsub#publisher-affiliation"
  def ns_pubsub_purge_nodes, do: "http://jabber.org/protocol/pubsub#purge-nodes"
  def ns_pubsub_retract_items, do: "http://jabber.org/protocol/pubsub#retract-items"
  def ns_pubsub_retrieve_affiliations, do: "http://jabber.org/protocol/pubsub#retrieve-affiliations"
  def ns_pubsub_retrieve_default, do: "http://jabber.org/protocol/pubsub#retrieve-default"
  def ns_pubsub_retrieve_items, do: "http://jabber.org/protocol/pubsub#retrieve-items"
  def ns_pubsub_retrieve_subscriptions, do: "http://jabber.org/protocol/pubsub#retrieve-subscriptions"
  def ns_pubsub_subscribe, do: "http://jabber.org/protocol/pubsub#subscribe"
  def ns_pubsub_subscription_options, do: "http://jabber.org/protocol/pubsub#subscription-options"
  def ns_pubsub_subscription_notifications, do: "http://jabber.org/protocol/pubsub#subscription-notifications"

  # Defined by XEP-0065: SOCKS5 Bytestreams.
  def ns_bytestreams, do: "http://jabber.org/protocol/bytestreams"

  # Defined by XEP-0066: Out of Band Data.
  ## How about NS_OOB instead ?
  def ns_oobd_iq, do: "jabber:iq:oob"
  def ns_oobd_x, do: "jabber:x:oob"

  # Defined by XEP-0070: Verifying HTTP Requests via XMPP.
  def ns_http_auth, do: "http://jabber.org/protocol/http-auth"

  # Defined by XEP-0071: XHTML-IM.
  def ns_xhtml_im, do: "http://jabber.org/protocol/xhtml-im"

  # Defined by XEP-0072: SOAP Over XMPP.
  def ns_soap_fault, do: "http://jabber.org/protocol/soap#fault"

  # Defined by XEP-0077: In-Band Registration.
  def ns_inband_register, do: "jabber:iq:register"
  def ns_inband_register_feat, do: "http://jabber.org/features/iq-register"

  # Defined by XEP-0078: Non-SASL Authentication.
  def ns_legacy_auth, do: "jabber:iq:auth"
  def ns_legacy_auth_feat, do: "http://jabber.org/features/iq-aut"

  # Defined by XEP-0079: Advanced Message Processing.
  def ns_amp, do: "http://jabber.org/protocol/amp"
  def ns_amp_errors, do: "http://jabber.org/protocol/amp#error"
  def ns_amp_feat, do: "http://jabber.org/features/amp"

  # Defined by XEP-0080: User Location.
  def ns_geoloc, do: "http://jabber.org/protocol/geoloc"

  # Defined by XEP-0083: Nested Roster Groups.
  def ns_roster_delimiter, do: "roster:delimiter"

  # Defined by XEP-0084: User Avatar.
  def ns_user_avatar_data, do: "urn:xmpp:avatar:data"

  def ns_user_avatar_metadata, do: "urn:xmpp:avatar:metadata"

  # Defined by XEP-0085: Chat State Notifications
  def ns_chatstates, do: "http://jabber.org/protocol/chatstates"

  # Defined by XEP-0090: Entity Time.
  def ns_time_old, do: "jabber:iq:time"

  # Defined by XEP-0091: Delayed Delivery.
  def ns_delay_old, do: "jabber:x:delay"

  # Defined by XEP-0092: Software Version.
  def ns_soft_version, do: "jabber:iq:version"

  # Defined by XEP-0093: Roster Item Exchange.
  def ns_roster_exchange_old, do: "jabber:x:roster"

  # Defined by XEP-0095: Stream Initiation.
  def ns_si, do: "http://jabber.org/protocol/si"

  # Defined by XEP-0096: File Transfer.
  def ns_file_transfert, do: "http://jabber.org/protocol/si/profile/file-transfer"

  # Defined by XEP-0100: Gateway Interaction.
  def ns_gateway, do: "jabber:iq:gateway"

  # Defined by XEP-0107: User Mood.
  def ns_user_mood, do: "http://jabber.org/protocol/mood"

  # Defined by XEP-0108: User Activity.
  def ns_user_activity, do: "http://jabber.org/protocol/activity"

  # Defined by XEP-0112: User Physical Location  Deferred).
  def ns_user_physloc, do: "http://jabber.org/protocol/physloc"

  # Defined by XEP-0114: Jabber Component Protocol.
  def ns_component_accept, do: "jabber:component:accept"
  def ns_component_connect, do: "jabber:component:connect"

  # Defined by XEP-0115: Entity Capabilities.
  def ns_caps, do: "http://jabber.org/protocol/caps"

  # Defined by XEP-0118: User Tune.
  def ns_user_tune, do: "http://jabber.org/protocol/tune"

  # Defined by XEP-0122: Data Forms Validation.
  def ns_data_forms_validate, do: "http://jabber.org/protocol/xdata-validate"

  # Defined by XEP-0124: Bidirectional-streams Over Synchronous HTTP.
  def ns_bosh, do: "urn:xmpp:xbosh"

  def ns_http_bind, do: "http://jabber.org/protocol/httpbind"

  # Defined by XEP-0130: Waiting Lists.
  def ns_waiting_list, do: "http://jabber.org/protocol/waitinglist"

  # Defined by XEP-0131: Stanza Headers and Internet Metadata  SHIM).
  def ns_shim, do: "http://jabber.org/protocol/shim"

  # Defined by XEP-0133: Service Administration.
  def ns_admin, do: "http://jabber.org/protocol/admin"

  # Defined by XEP-0136: Message Archiving.
  def ns_archiving, do: "urn:xmpp:archive"

  # Defined by XEP-0137: Publishing Stream Initiation Requests.
  def ns_si_pub, do: "http://jabber.org/protocol/sipub"

  # Defined by XEP-0138: Stream Compression.
  def ns_compress, do: "http://jabber.org/protocol/compress"
  def ns_compress_feat, do: "http://jabber.org/features/compress"

  # Defined by XEP-0141: Data Forms Layout.
  def ns_data_forms_layout, do: "http://jabber.org/protocol/xdata-layout"

  # Defined by XEP-0144: Roster Item Exchange.
  def ns_roster_exchange, do: "http://jabber.org/protocol/rosterx"

  # Defined by XEP-0145: Annotations.
  def ns_roster_notes, do: "storage:rosternotes"

  # Defined by XEP-0153: vCard-Based Avatars.
  def ns_vcard_update, do: "vcard-temp:x:update"

  # Defined by XEP-0154: User Profile.
  def ns_user_profile, do: "urn:xmpp:tmp:profile"

  # Defined by XEP-0155: Stanza Session Negotiation.
  def ns_ssn, do: "urn:xmpp:ssn"

  # Defined by XEP-0157: Contact Addresses for XMPP Services.
  def ns_serverinfo, do: "http://jabber.org/network/serverinfo"

  # Defined by XEP-0158: CAPTCHA Forms.
  def ns_captcha, do: "urn:xmpp:captcha"

  ## Deferred : XEP-0158: Robot Challenges
  def ns_robot_challenge, do: "urn:xmpp:tmp:challenge"

  # Defined by XEP-0160: Best Practices for Handling Offline Messages.
  def ns_msgoffline, do: "msgoffline"

  # Defined by XEP-0161: Abuse Reporting.
  def ns_abuse_reporting, do: "urn:xmpp:tmp:abuse"

  # Defined by XEP-0166: Jingle.
  def ns_jingle, do: "urn:xmpp:tmp:jingle"
  def ns_jingle_errors, do: "urn:xmpp:tmp:jingle:errors"

  # Defined by XEP-0167: Jingle RTP Sessions.
  def ns_jingle_rpt, do: "urn:xmpp:tmp:jingle:apps:rtp"
  def ns_jingle_rpt_info, do: "urn:xmpp:tmp:jingle:apps:rtp:info"

  # Defined by XEP-0168: Resource Application Priority.
  def ns_rap, do: "http://www.xmpp.org/extensions/xep-0168.html#ns"
  def ns_rap_route, do: "http://www.xmpp.org/extensions/xep-0168.html#ns-route"

  # Defined by XEP-0171: Language Translation.
  def ns_lang_trans, do: "urn:xmpp:langtrans"
  def ns_lang_trans_items, do: "urn:xmpp:langtrans#items"

  # Defined by XEP-0172: User Nickname.
  def ns_user_nickname, do: "http://jabber.org/protocol/nick"

  # Defined by XEP-0176: Jingle ICE-UDP Transport Method.
  def ns_jingle_ice_udp, do: "urn:xmpp:tmp:jingle:transports:ice-udp"

  # Defined by XEP-0177: Jingle Raw UDP Transport Method.
  def ns_jingle_raw_udp, do: "urn:xmpp:tmp:jingle:transports:raw-udp"
  def ns_jingle_raw_udp_info, do: "urn:xmpp:tmp:jingle:transports:raw-udp:info"

  # Defined by XEP-0181: Jingle DTMF.
  def ns_jingle_dtmf_0, do: "urn:xmpp:jingle:dtmf:0"

  ## Deferred
  def ns_jingle_dtmf, do: "urn:xmpp:tmp:jingle:dtmf"

  # Defined by XEP-0184: Message Receipts.
  def ns_receipts, do: "urn:xmpp:receipts"

  # Defined by XEP-0186: Invisible Command.
  def ns_invisible_command_0, do: "urn:xmpp:invisible:0"

  ## Deferred
  def ns_invisible_command, do: "urn:xmpp:tmp:invisible"

  # Defined by XEP-0189: Public Key Publishing.
  def ns_pubkey_1, do: "urn:xmpp:pubkey:1"

  def ns_attest_1, do: "urn:xmpp:attest:1"

  def ns_revoke_1, do: "urn:xmpp:revoke:1"

  ## Deferred
  def ns_pubkey_tmp, do: "urn:xmpp:tmp:pubkey"

  # Defined by XEP-0191: Simple Communications Blocking.
  def ns_blocking, do: "urn:xmpp:blocking"
  def ns_blocking_errors, do: "urn:xmpp:blocking:errors"

  # Defined by XEP-0194: User Chatting.
  def ns_user_chatting_0, do: "urn:xmpp:chatting:0"

  ## Deferred
  def ns_user_chatting, do: "http://www.xmpp.org/extensions/xep-0194.html#ns"

  # Defined by XEP-0195: User Browsing.
  def ns_user_browsing_0, do: "urn:xmpp:browsing:0"

  ## Deferred
  def ns_user_browsing, do: "http://www.xmpp.org/extensions/xep-0195.html#ns"

  # Defined by XEP-0196: User Gaming.
  def ns_user_gaming_0, do: "urn:xmpp:gaming:0"

  ## Deferred
  def ns_user_gaming, do: "http://www.xmpp.org/extensions/xep-0196.html#ns"

  # Defined by XEP-0197: User Viewing.
  def ns_user_viewing_0, do: "urn:xmpp:viewing:0"

  ## Deferred
  def ns_user_viewing, do: "http://www.xmpp.org/extensions/xep-0197.html#ns"

  # Defined by XEP-0198: Stream Management.
  def ns_stream_mgnt_3, do: "urn:xmpp:sm:3"

  ## Deferred
  def ns_stream_mgnt_2, do: "urn:xmpp:sm:2"
  def ns_stream_mgnt_1, do: "urn:xmpp:sm:1"
  def ns_stream_mgnt_0, do: "urn:xmpp:sm:0"
  def ns_stanza_ack, do: "http://www.xmpp.org/extensions/xep-0198.html#ns"

  # Defined by XEP-0199: XMPP Ping.
  def ns_ping, do: "urn:xmpp:ping"

  # Defined by XEP-0202: Entity Time.
  def ns_time, do: "urn:xmpp:time"

  # Defined by XEP-0203: Delayed Delivery.
  def ns_delay, do: "urn:xmpp:delay"

  # Defined by XEP-0206: XMPP Over BOSH.
  def ns_xbosh, do: "urn:xmpp:xbosh"

  # Defined by XEP-0208: Bootstrapping Implementation of Jingle.
  def ns_jingle_bootstraping, do: "http://www.xmpp.org/extensions/xep-0208.html#ns"

  # Defined by XEP-0209: Metacontacts.
  def ns_metacontacts, do: "storage:metacontacts"

  # Defined by XEP-0215: External Service Discovery.
  def ns_external_disco_0, do: "urn:xmpp:extdisco:0"

  ## Deferred
  def ns_external_disco, do: "http://www.xmpp.org/extensions/xep-0215.html#ns"

  # Defined by XEP-0220: Server Dialback.
  def ns_dialback, do: "jabber:server:dialback"
  def ns_dialback_feat, do: "urn:xmpp:features:dialback"

  # Defined by XEP-0221: Data Forms Media Element.
  ## How about NS_DATA ?
  def ns_data_forms_media, do: "urn:xmpp:media-element"

  ## Deferred
  def ns_data_forms_media_tmp, do: "urn:xmpp:tmp:media-element"

  # Defined by XEP-0224: Attention.
  def ns_attention_0, do: "urn:xmpp:attention:0"

  ## Deferred
  def ns_attention, do: "http://www.xmpp.org/extensions/xep-0224.html#ns"

  # Defined by XEP-0225: Component Connections.
  def ns_component_connection_0, do: "urn:xmpp:component:0"

  ## Deferred
  def ns_component_connection, do: "urn:xmpp:tmp:component"

  # Defined by XEP-0227: Portable Import/Export Format for XMPP-IM Servers.
  def ns_server_import_export, do: "http://www.xmpp.org/extensions/xep-0227.html#ns"

  # Defined by XEP-0231: Data Element.
  def ns_bob, do: "urn:xmpp:bob"

  ## Deferred
  def ns_data, do: "urn:xmpp:tmp:data-element"

  # Defined by XEP-0233: Use of Domain-Based Service Names in XMPP SASL
  # Negotiation.
  def ns_domain_based_name, do: "urn:xmpp:tmp:domain-based-name"
  def ns_domain_based_name_b, do: "urn:xmpp:tmp:domain-based-name"

  # Defined by XEP-0234: Jingle File Transfer.
  def ns_jingle_ft_1, do: "urn:xmpp:jingle:apps:file-transfer:1"

  ## Deferred
  def ns_jingle_file_transfert, do: "urn:xmpp:tmp:jingle:apps:file-transfer"

  # Defined by XEP-0235: Authorization Tokens.
  def ns_oauth_0, do: "urn:xmpp:oauth:0"

  def ns_oauth_errors_0, do: "urn:xmpp:oauth:0:errors"

  ## Deferred : XEP-0235: Authorization Tokens.
  def ns_auth_token, do: "urn:xmpp:tmp:auth-token"

  # Defined by XEP-0237: Roster Versioning.
  def ns_roster_ver, do: "urn:xmpp:features:rosterver"

  ## Deferred : XEP-0237: Roster Sequencing.
  def ns_roster_seq, do: "urn:xmpp:tmp:roster-sequencing"

  # Defined by XEP-0244: IO Data.
  def ns_io_data_tmp, do: "urn:xmpp:tmp:io-data"

  # Defined by XEP-0247: Jingle XML Streams.
  def ns_jingle_xml_stream_0, do: "urn:xmpp:jingle:apps:xmlstream:0"

  # Deferred
  def ns_jingle_xml_stream, do: "urn:xmpp:tmp:jingle:apps:xmlstream"

  # Defined by XEP-0249: Direct MUC Invitations.
  def ns_jabber_x_conf, do: "jabber:x:conference"

  # Defined by XEP-0251: Jingle Session Transfer.
  def ns_jingle_transfer_0, do: "urn:xmpp:jingle:transfer:0"

  # Defined by XEP-0253: PubSub Chaining.
  def ns_pubsub_chaining, do: "http://jabber.org/protocol/pubsub#chaining"

  # Defined by XEP-0254: PubSub Queueing.
  def ns_pubsub_queueing_0, do: "urn:xmpp:pubsub:queueing:0"

  # Defined by XEP-0255: Location Query.
  def ns_location_query_0, do: "urn:xmpp:locationquery:0"

  # Defined by XEP-0257: Client Certificate Management for SASL EXTERNAL.
  def ns_sasl_cert_0, do: "urn:xmpp:saslcert:0"

  # Defined by XEP-0258: Security Labels in XMPP.
  def ns_sec_label_0, do: "urn:xmpp:sec-label:0"

  def ns_sec_label_catalog_1, do: "urn:xmpp:sec-label:catalog:1"

  def ns_sec_label_ess_0, do: "urn:xmpp:sec-label:ess:0"

  # Defined by XEP-0259: Message Mine-ing.
  def ns_mine_tmp_0, do: "urn:xmpp:tmp:mine:0"

  # Defined by XEP-0260: Jingle SOCKS5 Bytestreams Transport Method.
  def ns_jingle_transports_s5b_1, do: "urn:xmpp:jingle:transports:s5b:1"

  # Defined by XEP-0261: Jingle In-Band Bytestreams Transport Method.
  def ns_jingle_transports_s5b_0, do: "urn:xmpp:jingle:transports:s5b:0"

  # Defined by XEP-0262: Use of ZRTP in Jingle RTP Sessions.
  def ns_jingle_apps_rtp_zrtp_0, do: "urn:xmpp:jingle:apps:rtp:zrtp:0"

  # Defined by XEP-0264: File Transfer Thumbnails.
  def ns_ft_thumbs_0, do: "urn:xmpp:thumbs:0"

  # Defined by XEP-0265: Out-of-Band Stream Data.
  def ns_jingle_apps_oob_0, do: "urn:xmpp:jingle:apps:out-of-band:0"

  # Defined by XEP-0268: Incident Reporting.
  def ns_incident_report_0, do: "urn:xmpp:incident:0"

  # Defined by XEP-0272: Multiparty Jingle  Muji).
  def ns_telepathy_muji, do: "http://telepathy.freedesktop.org/muji"

  # Defined by XEP-0273: Stanza Interception and Filtering Technology  SIFT).
  def ns_sift_1, do: "urn:xmpp:sift:1"

  # Defined by XEP-0275: Entity Reputation.
  def ns_reputation_0, do: "urn:xmpp:reputation:0"

  # Defined by XEP-0276: Temporary Presence Sharing.
  def ns_temppres_0, do: "urn:xmpp:temppres:0"

  # Defined by XEP-0277: Microblogging over XMPP.
  def ns_mublog_0, do: "urn:xmpp:microblog:0"

  # Defined by XEP-0278: Jingle Relay Nodes.
  def ns_jingle_relay_nodes, do: "http://jabber.org/protocol/jinglenodes"

  # Defined by XEP-0279: Server IP Check.
  def ns_sic_0, do: "urn:xmpp:sic:0"

  # Defined by XHTML 1.0.
  def ns_xhtml, do: "http://www.w3.org/1999/xhtml"
end
