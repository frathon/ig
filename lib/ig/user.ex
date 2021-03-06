defmodule Ig.User do
  @moduledoc """
  User represents single login details and does all
  the heavy lifting for Ig process and holds all account
  related informations in it's state:

  ```
  defstruct [
      demo: false,
      identifier: nil,
      password: nil,
      api_key: nil,
      cst: nil,
      security_token: nil,
      account_type: nil,
      account_info: %{},
      currency_iso_code: nil,
      currency_symbol: nil,
      current_account_id: nil,
      lightstreamer_endpoint: nil,
      accounts: [],
      client_id: nil,
      timezone_offset: 0,
      has_active_demo_accounts: true,
      has_active_live_accounts: true,
      trailing_stops_enabled: false,
      rerouting_environment: null,
      dealing_enabled: true
  ]
  ```
  """

  use GenServer

  defmodule State do
    defstruct demo: false,
              identifier: nil,
              password: nil,
              api_key: nil,
              cst: nil,
              security_token: nil,
              account_type: nil,
              account_info: %{},
              currency_iso_code: nil,
              currency_symbol: nil,
              current_account_id: nil,
              lightstreamer_endpoint: nil,
              accounts: [],
              client_id: nil,
              timezone_offset: 0,
              has_active_demo_accounts: true,
              has_active_live_accounts: true,
              trailing_stops_enabled: false,
              rerouting_environment: nil,
              dealing_enabled: true

    use ExConstructor
  end

  def start_link(arguments, options \\ []) do
    GenServer.start_link(__MODULE__, arguments, options)
  end

  def init(account_details) do
    {:ok, State.new(account_details)}
  end

  @doc """
  Returns the user's session details.

  Version: 1
  API Docs: https://labs.ig.com/rest-trading-api-reference/service-detail?id=534
  """
  def login(pid) do
    GenServer.call(pid, :login)
  end

  @doc """
  Returns a list of accounts belonging to the logged-in client.

  Version: 1
  API Docs: https://labs.ig.com/rest-trading-api-reference/service-detail?id=553
  """
  def accounts(pid) do
    GenServer.call(pid, :accounts)
  end

  @doc """
  Returns account preferences.

  Version: 1
  API Docs: https://labs.ig.com/rest-trading-api-reference/service-detail?id=531
  """
  def account_preferences(pid) do
    GenServer.call(pid, :account_preferences)
  end

  @doc """
  Returns the account activity history.

  Optional params:
  - from     (DateTime)	Start date
  - to       (DateTime)	End date (Default = current time. A date without time component refers to the end of that day.)
  - detailed (boolean) 	Indicates whether to retrieve additional details about the activity (default = false)
  - dealId   (String) 	Deal ID
  - filter   (String) 	FIQL filter (supported operators: ==|!=|,|;)
  - pageSize (int) 	    Page size (min: 10, max: 500) (Default = 50)

  Version: 1
  API Docs: https://labs.ig.com/rest-trading-api-reference/service-detail?id=543
  """
  @spec activity_history(pid(), [keyword()]) :: {:ok, %{}}
  def activity_history(pid, [_ | _] = optional_args) do
    GenServer.call(pid, {:activity_history, optional_args})
  end

  @doc """
  Returns the account activity history for the last specified period.

  last_period is an interval in milliseconds

  Version: 1
  API Docs: https://labs.ig.com/rest-trading-api-reference/service-detail?id=549
  """
  @spec activity_history(pid(), integer()) :: {:ok, %{}}
  def activity_history(pid, last_period) when is_integer(last_period) do
    GenServer.call(pid, {:activity_history, last_period})
  end

  @doc """
  Returns the account activity history for the given date range.

  Both from_date and to_date should be string in dd-mm-yyyy format

  Version: 1
  API Docs: https://labs.ig.com/rest-trading-api-reference/service-detail?id=539
  """
  @spec activity_history(pid(), String.t(), String.t()) :: {:ok, %{}}
  def activity_history(pid, from_date, to_date) do
    # todo: check dd-mm-yyyy format here
    GenServer.call(pid, {:activity_history, from_date, to_date})
  end

  @doc """
  Returns the transaction history. By default returns the minute prices within the last 10 minutes.

  Optional params:
  - type           (String)   Transaction type ALL | ALL_DEAL | DEPOSIT | WITHDRAWAL (default = ALL)
  - from           (DateTime) Start date
  - to             (DateTime) End date (date without time refers to the end of that day)
  - maxSpanSeconds (int) 	    Limits the timespan in seconds through to current time (not applicable if a date range has been specified) (default = 600)
  - pageSize       (int)      Page size (disable paging = 0) (default = 20)
  -	pageNumber     (int)      Page number (default = 1)

  Version: 2
  API Docs: https://labs.ig.com/rest-trading-api-reference/service-detail?id=525
  """
  @spec transactions(pid(), [keyword()]) :: {:ok, %{}}
  def transactions(pid, [_ | _] = optional_args) do
    GenServer.call(pid, {:transactions, optional_args})
  end

  @doc """
  Returns all open positions for the active account.

  Version: 2
  API Docs: https://labs.ig.com/rest-trading-api-reference/service-detail?id=545
  """
  @spec positions(pid()) :: {:ok, %{}}
  def positions(pid) do
    GenServer.call(pid, :positions)
  end

  @doc """
  Returns an open position for the active account by deal identifier.

  Version: 2
  API Docs: https://labs.ig.com/rest-trading-api-reference/service-detail?id=541
  """
  @spec position(pid(), String.t()) :: {:ok, %{}}
  def position(pid, deal_id) do
    GenServer.call(pid, {:position, deal_id})
  end

  def get_state(pid) when is_pid(pid) do
    GenServer.call(pid, :get_state)
  end

  @doc """
  Returns all top-level nodes (market categories) in the market navigation hierarchy.

  Version: 1
  API Docs: https://labs.ig.com/rest-trading-api-reference/service-detail?id=550
  """
  def market_navigation(pid) do
    GenServer.call(pid, :market_navigation)
  end

  @doc """
  Returns all sub-nodes of the given node in the market navigation hierarchy.

  Require params:
  - nodeId  (String)  The identifier of the node to browse

  Version: 1
  API Docs: https://labs.ig.com/rest-trading-api-reference/service-detail?id=544
  """
  def market_navigation(pid, node_id) do
    GenServer.call(pid, {:market_navigation, node_id})
  end

  @doc """
  Returns the details of the given market.

  Require params:
  - epic  (String)  The epic of the market to be retrieved

  Version: 3
  API Docs: https://labs.ig.com/rest-trading-api-reference/service-detail?id=528
  """
  def markets(pid, epic) do
    GenServer.call(pid, {:markets, epic})
  end

  @doc """
  Returns the details of the given markets.

  Require params:
  - epics  (String)  The epic of the market to be retrieved

  Optional params:
  (Default = ALL)
  - filter (MarketDetailsFilterType)	MarketDetailsFilterType
                                      Filter for the market details
                                      ALL	          Display all market details. Market details includes all instrument 
                                                    data, dealing rules and market snapshot values for all epics 
                                                    specified.
                                      SNAPSHOT_ONLY	Display the market snapshot and minimal instrument data fields. 
                                                    This mode is faster because it only sets the epic and instrument 
                                                    type in the instrument data and the market data snapshot values 
                                                    with all the other fields being unset for each epic specified.

  Version: 2
  API Docs: https://labs.ig.com/rest-trading-api-reference/service-detail?id=524
  """
  def markets(pid, epics, filter \\ "ALL") do
    GenServer.call(pid, {:markets, epics, filter: filter})
  end

  @doc """
  Returns historical prices for a particular instrument. By default returns the minute prices within the last 10 minutes.

  Require params:
  - epic  (String)  Instrument epic

  Optional params:
  - resolution  (Resolution)  Price resolution
                              Defines the resolution of requested prices.
                              DAY	        1 day
                              HOUR	      1 hour
                              HOUR_2	    2 hours
                              HOUR_3	    3 hours
                              HOUR_4	    4 hours
                              MINUTE	    1 minute
                              MINUTE_10	  10 minutes
                              MINUTE_15	  15 minutes
                              MINUTE_2	  2 minutes
                              MINUTE_3	  3 minutes
                              MINUTE_30	  30 minutes
                              MINUTE_5	  5 minutes
                              MONTH	      1 month
                              SECOND	    1 second
                              WEEK	      1 week
  - from        (DateTime)	  Start date time (yyyy-MM-dd'T'HH:mm:ss)
  - to          (DateTime)	  End date time (yyyy-MM-dd'T'HH:mm:ss)
  - max         (int)	        Limits the number of price points (not applicable if a date range has been specified)
  - pageSize    (int)	        Page size (disable paging = 0)
  - pageNumber  (int)         Page number
                              
  Version: 3
  API Docs: https://labs.ig.com/rest-trading-api-reference/service-detail?id=521
  """
  def prices(pid, epic) do
    GenServer.call(pid, {:prices, epic})
  end

  @doc """
  Returns a list of historical prices for the given epic, resolution and number of data points

  Require params:
  - epic        (String)      Instrument epic
  - resolution  (Resolution)	Price resolution (MINUTE, MINUTE_2, MINUTE_3, MINUTE_5, MINUTE_10, MINUTE_15, MINUTE_30, 
                              HOUR, HOUR_2, HOUR_3, HOUR_4, DAY, WEEK, MONTH)
  - numPoints   (int)	        Number of data points required

  Version: 2
  API Docs: https://labs.ig.com/rest-trading-api-reference/service-detail?id=552
  """
  def prices(pid, epic, resolution, num_points) do
    GenServer.call(pid, {:prices, epic, resolution, num_points})
  end

  @doc """
  Returns a list of historical prices for the given epic, resolution and date range.

  Require params:
  - epic        (String)      Instrument epic
  - resolution  (Resolution)	Price resolution (MINUTE, MINUTE_2, MINUTE_3, MINUTE_5, MINUTE_10, MINUTE_15, MINUTE_30, 
                              HOUR, HOUR_2, HOUR_3, HOUR_4, DAY, WEEK, MONTH)
  - startDate   (String)	    Start date (yyyy-MM-dd HH:mm:ss)
  - endDate     (String)	    End date (yyyy-MM-dd HH:mm:ss). Must be later then the start date.

  Version: 2
  API Docs: https://labs.ig.com/rest-trading-api-reference/service-detail?id=530
  """
  def prices(pid, epic, resolution, start_date, end_date) do
    GenServer.call(pid, {:prices, epic, resolution, start_date, end_date})
  end

  ## Callbacks

  def handle_call(:get_state, _from, state) do
    {:reply, state, state}
  end

  def handle_call(:login, _from, %State{
        identifier: identifier,
        password: password,
        api_key: api_key,
        demo: demo
      }) do
    {:ok, result} = Ig.RestClient.login(demo, identifier, password, api_key)

    new_state = %{
      State.new(result)
      | identifier: identifier,
        password: password,
        api_key: api_key,
        demo: demo
    }

    {:reply, {:ok, new_state}, new_state}
  end

  def handle_call(
        :accounts,
        _from,
        %State{cst: cst, api_key: api_key, demo: demo, security_token: security_token} = state
      ) do
    {:ok, %HTTPoison.Response{body: body}} =
      Ig.RestClient.get(demo, '/accounts', [
        {"X-IG-API-KEY", api_key},
        {"X-SECURITY-TOKEN", security_token},
        {"CST", cst},
        {"VERSION", 1}
      ])

    response_body = Jason.decode!(body)

    accounts =
      response_body["accounts"]
      |> Enum.map(&Ig.Account.new/1)

    {:reply, {:ok, accounts}, state}
  end

  def handle_call(
        :account_preferences,
        _from,
        %State{cst: cst, api_key: api_key, demo: demo, security_token: security_token} = state
      ) do
    {:ok, %HTTPoison.Response{body: body}} =
      Ig.RestClient.get(demo, '/accounts/preferences', [
        {"X-IG-API-KEY", api_key},
        {"X-SECURITY-TOKEN", security_token},
        {"CST", cst},
        {"VERSION", 1}
      ])

    response_body = Jason.decode!(body)

    account_preference = Ig.AccountPreference.new(response_body)

    {:reply, {:ok, account_preference}, state}
  end

  def handle_call(
        {:activity_history, [_ | _] = optional_args},
        _from,
        %State{cst: cst, api_key: api_key, demo: demo, security_token: security_token} = state
      ) do
    params = URI.encode_query(optional_args)

    {:ok, %HTTPoison.Response{body: body}} =
      Ig.RestClient.get(demo, "/history/activity?#{params}", [
        {"X-IG-API-KEY", api_key},
        {"X-SECURITY-TOKEN", security_token},
        {"CST", cst},
        {"VERSION", 3}
      ])

    result =
      body
      |> decode_activities()

    {:reply, {:ok, result}, state}
  end

  def handle_call(
        {:activity_history, from_date, to_date},
        _from,
        %State{cst: cst, api_key: api_key, demo: demo, security_token: security_token} = state
      ) do
    {:ok, %HTTPoison.Response{body: body}} =
      Ig.RestClient.get(demo, "/history/activity/#{from_date}/#{to_date}", [
        {"X-IG-API-KEY", api_key},
        {"X-SECURITY-TOKEN", security_token},
        {"CST", cst},
        {"VERSION", 1}
      ])

    %{"activities" => activities_list} =
      body
      |> Jason.decode!()

    result = %{
      activities:
        activities_list
        |> Enum.map(&decode_activity/1)
    }

    {:reply, {:ok, result}, state}
  end

  def handle_call(
        {:activity_history, last_period},
        _from,
        %State{cst: cst, api_key: api_key, demo: demo, security_token: security_token} = state
      )
      when is_integer(last_period) do
    {:ok, %HTTPoison.Response{body: body}} =
      Ig.RestClient.get(demo, "/history/activity/#{last_period}", [
        {"X-IG-API-KEY", api_key},
        {"X-SECURITY-TOKEN", security_token},
        {"CST", cst},
        {"VERSION", 1}
      ])

    %{"activities" => activities_list} =
      body
      |> Jason.decode!()

    result = %{
      activities:
        activities_list
        |> Enum.map(&decode_activity/1)
    }

    {:reply, {:ok, result}, state}
  end

  def handle_call(
        {:transactions, [_ | _] = optional_args},
        _from,
        %State{cst: cst, api_key: api_key, demo: demo, security_token: security_token} = state
      ) do
    params = URI.encode_query(optional_args)

    {:ok, %HTTPoison.Response{body: body}} =
      Ig.RestClient.get(demo, "/history/transactions?#{params}", [
        {"X-IG-API-KEY", api_key},
        {"X-SECURITY-TOKEN", security_token},
        {"CST", cst},
        {"VERSION", 2}
      ])

    result =
      body
      |> decode_transactions()

    {:reply, {:ok, result}, state}
  end

  def handle_call(
        :positions,
        _from,
        %State{cst: cst, api_key: api_key, demo: demo, security_token: security_token} = state
      ) do
    {:ok, %HTTPoison.Response{body: body}} =
      Ig.RestClient.get(demo, "/positions", [
        {"X-IG-API-KEY", api_key},
        {"X-SECURITY-TOKEN", security_token},
        {"CST", cst},
        {"VERSION", 2}
      ])

    %{"positions" => positions_list} =
      body
      |> Jason.decode!()

    result = %{
      positions:
        positions_list
        |> Enum.map(&decode_position/1)
    }

    {:reply, {:ok, result}, state}
  end

  def handle_call(
        {:position, deal_id},
        _from,
        %State{cst: cst, api_key: api_key, demo: demo, security_token: security_token} = state
      ) do
    {:ok, %HTTPoison.Response{body: body}} =
      Ig.RestClient.get(demo, "/positions/#{deal_id}", [
        {"X-IG-API-KEY", api_key},
        {"X-SECURITY-TOKEN", security_token},
        {"CST", cst},
        {"VERSION", 2}
      ])

    result =
      body
      |> Jason.decode!()
      |> decode_position()

    {:reply, {:ok, result}, state}
  end

  def handle_call(
        :market_navigation,
        _from,
        %State{cst: cst, api_key: api_key, demo: demo, security_token: security_token} = state
      ) do
    {:ok, %HTTPoison.Response{body: body}} =
      Ig.RestClient.get(demo, "/marketnavigation", [
        {"X-IG-API-KEY", api_key},
        {"X-SECURITY-TOKEN", security_token},
        {"CST", cst},
        {"VERSION", 1}
      ])

    response = decode_market_navigation(body)

    {:reply, {:ok, response}, state}
  end

  def handle_call(
        {:market_navigation, node_id},
        _from,
        %State{cst: cst, api_key: api_key, demo: demo, security_token: security_token} = state
      ) do
    {:ok, %HTTPoison.Response{body: body}} =
      Ig.RestClient.get(demo, "/marketnavigation/#{node_id}", [
        {"X-IG-API-KEY", api_key},
        {"X-SECURITY-TOKEN", security_token},
        {"CST", cst},
        {"VERSION", 1}
      ])

    response_body = decode_market_navigation_node_id(body)

    {:reply, {:ok, response_body}, state}
  end

  def handle_call(
        {:markets, epic},
        _from,
        %State{cst: cst, api_key: api_key, demo: demo, security_token: security_token} = state
      ) do
    {:ok, %HTTPoison.Response{body: body}} =
      Ig.RestClient.get(demo, "/markets/#{epic}", [
        {"X-IG-API-KEY", api_key},
        {"X-SECURITY-TOKEN", security_token},
        {"CST", cst},
        {"VERSION", 3}
      ])

    response_body = decode_markets(body)

    {:reply, {:ok, response_body}, state}
  end

  def handle_call(
        {:markets, epics, filters},
        _from,
        %State{cst: cst, api_key: api_key, demo: demo, security_token: security_token} = state
      ) do
    params = URI.encode_query(filters)

    {:ok, %HTTPoison.Response{body: body}} =
      Ig.RestClient.get(demo, "/markets/#{epics}?#{params}", [
        {"X-IG-API-KEY", api_key},
        {"X-SECURITY-TOKEN", security_token},
        {"CST", cst},
        {"VERSION", 3}
      ])

    response_body = decode_markets(body)

    {:reply, {:ok, response_body}, state}
  end

  def handle_call(
        {:prices, epic},
        _from,
        %State{cst: cst, api_key: api_key, demo: demo, security_token: security_token} = state
      ) do
    {:ok, %HTTPoison.Response{body: body}} =
      Ig.RestClient.get(demo, "/prices/#{epic}", [
        {"X-IG-API-KEY", api_key},
        {"X-SECURITY-TOKEN", security_token},
        {"CST", cst},
        {"VERSION", 3}
      ])

    response_body = decode_prices(body)

    {:reply, {:ok, response_body}, state}
  end

  def handle_call(
        {:prices, epics, [_ | _] = optional_args},
        _from,
        %State{cst: cst, api_key: api_key, demo: demo, security_token: security_token} = state
      ) do
    params = URI.encode_query(optional_args)

    {:ok, %HTTPoison.Response{body: body}} =
      Ig.RestClient.get(demo, '/prices/#{epics}?#{params}', [
        {"X-IG-API-KEY", api_key},
        {"X-SECURITY-TOKEN", security_token},
        {"CST", cst},
        {"VERSION", 3}
      ])

    response_body = decode_prices(body)

    {:reply, {:ok, response_body}, state}
  end

  def handle_call(
        {:prices, epic, resolution, num_points},
        _from,
        %State{cst: cst, api_key: api_key, demo: demo, security_token: security_token} = state
      ) do
    {:ok, %HTTPoison.Response{body: body}} =
      Ig.RestClient.get(demo, '/prices/#{epic}/#{resolution}/#{num_points}', [
        {"X-IG-API-KEY", api_key},
        {"X-SECURITY-TOKEN", security_token},
        {"CST", cst},
        {"VERSION", 2}
      ])

    response_body = decode_prices_with_points(body)

    {:reply, {:ok, response_body}, state}
  end

  def handle_call(
        {:prices, epic, resolution, start_date, end_date},
        _from,
        %State{cst: cst, api_key: api_key, demo: demo, security_token: security_token} = state
      ) do
    {:ok, %HTTPoison.Response{body: body}} =
      Ig.RestClient.get(demo, "/prices/#{epic}/#{resolution}/#{start_date}/#{end_date}", [
        {"X-IG-API-KEY", api_key},
        {"X-SECURITY-TOKEN", security_token},
        {"CST", cst},
        {"VERSION", 2}
      ])

    response_body = decode_prices_with_points(body)

    {:reply, {:ok, response_body}, state}
  end

  defp decode_position(%{"market" => market, "position" => position}) do
    %{
      market: Ig.Market.new(market),
      position: Ig.Position.new(position)
    }
  end

  defp decode_activities(body) do
    %{
      "activities" => activities_list,
      "metadata" => %{
        "paging" => %{
          "next" => paging_next,
          "size" => paging_size
        }
      }
    } = Jason.decode!(body)

    %{
      activities:
        activities_list
        |> Enum.map(&decode_activity/1),
      metadata: %{paging: %{next: paging_next, size: paging_size}}
    }
  end

  defp decode_transactions(body) do
    %{
      "transactions" => transactions_list,
      "metadata" => %{
        "pageData" => %{
          "pageNumber" => page_number,
          "pageSize" => page_size,
          "totalPages" => total_pages
        },
        "size" => size
      }
    } = Jason.decode!(body)

    %{
      transactions:
        transactions_list
        |> Enum.map(&Ig.Transaction.new/1),
      metadata: %{
        page_data: %{page_number: page_number, page_size: page_size, total_pages: total_pages},
        size: size
      }
    }
  end

  #####
  # Note: Activities can have no `details`
  #####
  defp decode_activity(activity) do
    activity_struct = Ig.HistoricalActivity.new(activity)

    activity_details =
      case activity_struct.details do
        nil -> nil
        details -> Ig.HistoricalActivityDetail.new(details)
      end

    %{activity_struct | details: activity_details}
  end

  defp decode_prices_with_points(body) do
    %{
      "prices" => prices_list,
      "instrumentType" => type,
      "allowance" => _allowance
    } = Jason.decode!(body)

    %{
      prices:
        prices_list
        |> Enum.map(&Ig.Prices.new/1),
      instrument_type: type
    }
  end

  defp decode_market_navigation(body) do
    %{
      "nodes" => nodes_list,
      "markets" => markets
    } = Jason.decode!(body)

    %{
      nodes:
        nodes_list
        |> Enum.map(&Ig.Node.new/1),
      markets: markets
    }
  end

  defp decode_market_navigation_node_id(body) do
    %{
      "nodes" => nodes,
      "markets" => markets_list
    } = Jason.decode!(body)

    %{
      nodes: nodes,
      markets:
        markets_list
        |> Enum.map(&Ig.Market.new/1)
    }
  end

  defp decode_prices(body) do
    %{
      "prices" => prices_list,
      "instrumentType" => type,
      "metadata" => %{
        "allowance" => _allowance,
        "size" => size,
        "pageData" => %{
          "pageSize" => page_size,
          "pageNumber" => page_number,
          "totalPages" => total_pages
        }
      }
    } = Jason.decode!(body)

    %{
      prices:
        prices_list
        |> Enum.map(&Ig.Prices.new/1),
      instrument_type: type,
      metadata: %{
        page_data: %{page_number: page_number, page_size: page_size, total_pages: total_pages},
        size: size
      }
    }
  end

  defp decode_markets(body) do
    %{
      "instrument" => instrument,
      "dealingRules" => dealing_rules,
      "snapshot" => snapshot
    } = Jason.decode!(body)

    %{
      instrument: instrument,
      dealing_rules: dealing_rules,
      snapshot: snapshot
    }
  end
end
