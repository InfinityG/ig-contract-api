require 'sinatra/base'
require './api/services/contract_service'
require './api/validators/contract_validator'
require 'json'

module Sinatra
  module ContractRoutes
    def self.registered(app)

      app.post '/contracts' do
        data = JSON.parse(request.body.read, :symbolize_names => true)

        # validation_result = ContractValidator.new.validate_contract data
        #
        # unless validation_result[:valid]
        #   status 500
        #   return validation_result.to_json
        # end

        result = ContractService.new.create_contract(data)

        status 200 # not 201 as this has just been submitted.
        return result.to_json

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
      app.put '/contracts/:contract_id/signatures/:signature_id' do

        contract_id = params[:contract_id]
        signature_id = params[:signature_id]

        data = JSON.parse(request.body.read, :symbolize_names => true)

        signature_value = data[:value]
        digest = data[:digest]
        participant_id = data[:participant_id]

        if (contract_id != nil && contract_id != '') && (signature_id != nil && signature_id != '')
          ContractService.new.sign_contract(contract_id, signature_id, participant_id, signature_value, digest)
          return  status 200
        end

        return status 404

      end

       # Sign a condition
      app.put '/contracts/:contract_id/conditions/:condition_id/signatures/:signature_id' do

        contract_id = params[:contract_id]
        condition_id = params[:condition_id]
        signature_id = params[:signature_id]

        data = JSON.parse(request.body.read, :symbolize_names => true)

        signature_value = data[:value]
        digest = data[:digest]
        participant_id = data[:participant_id]

        if (contract_id != nil && contract_id != '') && (condition_id != nil && condition_id != '') &&
            (signature_id != nil && signature_id != '')

          ContractService.new.sign_condition(contract_id, condition_id, signature_id, participant_id,
                                             signature_value, digest)
          return  status 200
        end

        return status 404

      end
    end
  end
end
