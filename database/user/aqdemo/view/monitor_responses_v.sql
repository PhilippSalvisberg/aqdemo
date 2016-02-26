CREATE OR REPLACE VIEW monitor_responses_v AS
SELECT res.corr_id,
       res.msg_state AS response_state,
       res.retry_count AS response_retry_count,
       res.consumer_name AS request_from,
       req.consumer_name AS response_by,
       req.user_data.get_string_property('appName') AS app_name,
       req.user_data.get_string_property('beanName') AS bean_name,
       req.user_data.text_vc AS request_text,
       res.user_data.text_vc AS response_text,
       req.enq_timestamp AS request_timestamp,
       res.enq_timestamp - req.enq_timestamp AS response_time
  FROM aq$responses_qt res
  JOIN aq$requests_qt req
    ON (req.corr_id = res.corr_id OR req.msg_id = res.corr_id)
 ORDER BY req.enq_time DESC;
