require 'spec_helper'

describe GooglePlaces::Request do

  before :each do
    @location = GooglePlaces::Location.new('-33.8670522', '151.1957362').format
    @query = "Statue of liberty, New York"
    @radius = 200
    @sensor = false
    @place_id = "ChIJky6hZN_QmoAR5AxFy70b-DA"
    @place_id_not_found = "abc123"
    @keyword = "attractions"
  end

  context 'Listing spots' do
    use_vcr_cassette 'list_spots'
    context 'with valid options' do
      it 'should retrieve a list of spots' do
        response = GooglePlaces::Request.spots(
          :location => @location,
          :radius => @radius,
          :sensor => @sensor,
          :key => api_key
        )
        response['results'].should_not be_empty
      end
    end
    context 'with missing sensor' do
      it do
        lambda {
          GooglePlaces::Request.spots(
            :location => @location,
            :radius => @radius,
            :key => api_key
          )
        }.should raise_error GooglePlaces::RequestDeniedError
      end
    end
    context 'without location' do
      context 'without retry options' do
        it do
          lambda {
            GooglePlaces::Request.spots(
              :radius => @radius,
              :sensor => @sensor,
              :key => api_key
            )
          }.should raise_error GooglePlaces::InvalidRequestError
        end
      end
      context 'with retry options' do
        context 'without timeout' do
          it do
            lambda {
              GooglePlaces::Request.spots(
                :radius => @radius,
                :sensor => @sensor,
                :key => api_key,
                :retry_options => {
                  :max => 3,
                  :status => 'INVALID_REQUEST',
                  :delay => 1
                }
              )
            }.should raise_error GooglePlaces::RetryError
          end
        end
        context 'with timeout' do
          it do
            lambda {
              GooglePlaces::Request.spots(
                :radius => @radius,
                :sensor => @sensor,
                :key => api_key,
                :retry_options => {
                  :max => 3,
                  :status => 'INVALID_REQUEST',
                  :delay => 10,
                  :timeout => 1
                }
              )
            }.should raise_error GooglePlaces::RetryTimeoutError
          end
        end
      end
    end
  end


  context 'Listing spots by query' do
    use_vcr_cassette 'list_spots'

    context 'with valid options' do
      it 'should retrieve a list of spots' do
        response = GooglePlaces::Request.spots_by_query(
          :query => @query,
          :sensor => @sensor,
          :key => api_key
        )

        response['results'].should_not be_empty
      end
    end

    context 'with missing sensor' do
      it do
        lambda {
          GooglePlaces::Request.spots_by_query(
            :query => @query,
            :key => api_key
          )
        }.should raise_error GooglePlaces::RequestDeniedError
      end
    end

    context 'without query' do
      context 'without retry options' do
        it do
          lambda {
            GooglePlaces::Request.spots_by_query(
              :sensor => @sensor,
              :key => api_key
            )
          }.should raise_error GooglePlaces::InvalidRequestError
        end
      end

      context 'with retry options' do
        context 'without timeout' do
          it do
            lambda {
              GooglePlaces::Request.spots_by_query(
                :sensor => @sensor,
                :key => api_key,
                :retry_options => {
                  :max => 3,
                  :status => 'INVALID_REQUEST',
                  :delay => 1
                }
              )
            }.should raise_error GooglePlaces::RetryError
          end
        end

        context 'with timeout' do
          it do
            lambda {
              GooglePlaces::Request.spots_by_query(
                :sensor => @sensor,
                :key => api_key,
                :retry_options => {
                  :max => 3,
                  :status => 'INVALID_REQUEST',
                  :delay => 10,
                  :timeout => 1
                }
              )
            }.should raise_error GooglePlaces::RetryTimeoutError
          end
        end
      end
    end
  end

  context 'Spot details' do
    use_vcr_cassette 'single_spot'
    context 'with valid options' do
      it 'should retrieve a single spot' do
        response = GooglePlaces::Request.spot(
          :place_id => @place_id,
          :sensor => @sensor,
          :key => api_key
        )
        response['result'].should_not be_empty
      end
      context 'with place_id not found' do
        it 'should raise not found error' do
          lambda {
            GooglePlaces::Request.spot(
              :place_id => @place_id_not_found,
              :sensor => @sensor,
              :key => api_key
            )
          }.should raise_error GooglePlaces::NotFoundError
        end
      end
    end
    context 'with missing sensor' do
      it do
        lambda {
          GooglePlaces::Request.spot(
            :place_id => @place_id,
            :key => api_key
          )
        }.should raise_error GooglePlaces::RequestDeniedError
      end
    end
    context 'with missing place_id' do
      context 'without retry options' do
        it do
          lambda {
            GooglePlaces::Request.spot(
              :sensor => @sensor,
              :key => api_key
            )
          }.should raise_error GooglePlaces::InvalidRequestError
        end
      end
      context 'with retry options' do
        context 'without timeout' do
          it do
            lambda {
              GooglePlaces::Request.spot(
                :sensor => @sensor,
                :key => api_key,
                :retry_options => {
                  :max => 3,
                  :status => 'INVALID_REQUEST',
                  :delay => 1
                }
              )
            }.should raise_error GooglePlaces::RetryError
          end
        end
        context 'with timeout' do
          it do
            lambda {
              GooglePlaces::Request.spot(
                :sensor => @sensor,
                :key => api_key,
                :retry_options => {
                  :max => 3,
                  :status => 'INVALID_REQUEST',
                  :delay => 10,
                  :timeout => 1
                }
              )
            }.should raise_error GooglePlaces::RetryTimeoutError
          end
        end
      end
    end
  end



  context 'Listing spots by radar' do
    use_vcr_cassette 'list_spots_by_radar'

    context 'with valid options' do
      context 'with keyword' do
        it do
          response = GooglePlaces::Request.spots_by_radar(
            :location => @location,
            :keyword => @keyword,
            :radius => @radius,
            :sensor => @sensor,
            :key => api_key
          ) 
          response['results'].should_not be_empty
        end
      end
      
      context 'with name' do
        it do
          response = GooglePlaces::Request.spots_by_radar(
            :location => @location,
            :name => 'park',
            :radius => @radius,
            :sensor => @sensor,
            :key => api_key
          )
          response['results'].should_not be_empty
        end
      end
    end

    context 'with missing sensor' do
      it do
        lambda {
          GooglePlaces::Request.spots_by_radar(
            :location => @location,
            :keyword => @keyword,
            :radius => @radius,
            :key => api_key
          )
        }.should raise_error GooglePlaces::RequestDeniedError
      end
    end

   context 'without keyword' do
      context 'without retry options' do
        it do
          lambda {
            GooglePlaces::Request.spots_by_radar(
              :location => @location,
              :radius => @radius,
              :sensor => @sensor,
              :key => api_key
            )
          }.should raise_error GooglePlaces::InvalidRequestError
        end
      end

      context 'with retry options' do
        context 'without timeout' do
          it do
            lambda {
              GooglePlaces::Request.spots_by_radar(
                :location => @location,
                :radius => @radius,
                :sensor => @sensor,
                :key => api_key,
                :retry_options => {
                  :max => 3,
                  :status => 'INVALID_REQUEST',
                  :delay => 1
                }
              )
            }.should raise_error GooglePlaces::RetryError
          end
        end

        context 'with timeout' do
          it do
            lambda {
              GooglePlaces::Request.spots_by_radar(
                :location => @location,
                :radius => @radius,
                :sensor => @sensor,
                :key => api_key,
                :retry_options => {
                  :max => 3,
                  :status => 'INVALID_REQUEST',
                  :delay => 10,
                  :timeout => 1
                }
              )
            }.should raise_error GooglePlaces::RetryTimeoutError
          end
        end
      end
    end
  end

end
