select
  -- Required Columns
  c ->> 'name' as resource,
  case
    when p ->> 'name' is null then 'skip'
    when cast(p ->> 'containerPort' as integer) <= 1024 then 'alarm'
    else 'ok'
  end as status,
  case
    when p ->> 'name' is null then 'No port mapped.'
    when cast(p ->> 'containerPort' as integer) <= 1024 then p ->> 'name' || ' mapped with a privileged port.'
    else p ->> 'name' || ' not mapped with a privileged port.'
  end as reason,
  -- Additional Dimensions
  name as statefulset_name,
  namespace,
  context_name
from
  kubernetes_stateful_set,
  jsonb_array_elements(template -> 'spec' -> 'containers') as c,
  jsonb_array_elements(c -> 'ports') as p;
