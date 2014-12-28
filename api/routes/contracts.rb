require 'sinatra/base'
require './api/services/contract_service'
require './api/validators/contract_validator'
require './api/errors/contract_error'
require 'json'

module Sinatra
  module ContractRoutes
    def self.registered(app)

      app.post '/contracts' do

        # parse
        data = begin
          JSON.parse(request.body.read, :symbolize_names => true)
        rescue
          status 400
          return 'Unable to parse JSON!'.to_json
        end

        # validate
        begin
          ContractValidator.new.validate_new_contract data
        rescue ValidationError => e
          status 400 # bad request
          return e.message
        end

        # create
        begin
          status 200 # not 201 as this has just been submitted.
          return ContractService.new.create_contract(data).to_json
        rescue ContractError => e
          status 400
          return e.message.to_json
        end

      end

      app.get '/contracts' do

        result = ContractService.new.get_contracts

        if result != nil
          status 200
          return result.to_json
        end

        return status 404

      end

      app.get '/contracts/:contract_id' do

        contract_id = params[:contract_id]

        if contract_id != nil
          result = ContractService.new.get_contract(contract_id)

          status 200
          return result.to_json
        end

        return status 404

      end

      app.get '/contracts/:contract_id/conditions/:condition_id' do

        contract_id = params[:contract_id]
        condition_id = params[:condition_id]

        if contract_id != nil && contract_id > 0
          contract = ContractService.new.get_contract(contract_id)
          result = nil

          contract.conditions.each do |condition|
            if condition.id == condition_id
              result = condition
            end
          end

          if result != nil
            status 200
            return result.to_json
          end
          return status 404
        end

        return status 404

      end

      # Sign a contract
      app.post '/contracts/:contract_id/signatures/:signature_id' do

        contract_id = params[:contract_id]
        signature_id = params[:signature_id]

        # parse
        data = begin
          JSON.parse(request.body.read, :symbolize_names => true)
        rescue
          status 400 # bad request
          return 'Unable to parse JSON!'.to_json
        end

        # validate
        begin
          ContractValidator.new.validate_updated_signature data
        rescue ValidationError => e
          status 400 # bad request
          return e.message
        end

        signature_value = data[:value]
        digest = data[:digest]

        # update
        begin
          status 200 # OK
          return ContractService.new.sign_contract(contract_id, signature_id, signature_value, digest).to_json
        rescue ContractError => e
          status 400
          return e.message.to_json
        end if (contract_id.to_s != '') && (signature_id.to_s != '')

        status 404 # not found
      end

      # Sign a condition
      app.post '/contracts/:contract_id/conditions/:condition_id/signatures/:signature_id' do

        contract_id = params[:contract_id]
        condition_id = params[:condition_id]
        signature_id = params[:signature_id]

        # parse
        data = begin
          JSON.parse(request.body.read, :symbolize_names => true)
        rescue
          status 400
          return 'Unable to parse JSON!'.to_json
        end

        signature_value = data[:value]
        digest = data[:digest]

        # update
        begin
          status 200 # OK
          return ContractService.new.sign_condition(contract_id, condition_id, signature_id,
                                                    signature_value, digest).to_json
        rescue ContractError => e
          status 400
          return e.message.to_json
        end if (contract_id.to_s != '') && (condition_id.to_s != '') && (signature_id.to_s != '')

        status 404 # not found
      end

    end
  end
end
