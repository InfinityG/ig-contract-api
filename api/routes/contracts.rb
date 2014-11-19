require 'sinatra/base'
require './api/services/contract_service'
require 'json'

module Sinatra
  module ContractRoutes
    def self.registered(app)

      app.post '/contracts' do
        data = JSON.parse(request.body.read, :symbolize_names => true)

        #TODO: validation
        name = data[:name]
        description = data[:description]
        expires = data[:expires]
        target_wallet_address = data[:target_wallet_address]
        target_wallet_tag = data[:target_wallet_tag]
        value = data[:value]
        conditions = data[:conditions]

        result = ContractService.new.create_contract(name, description, expires, target_wallet_address,
                                                     target_wallet_tag, value, conditions)

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

      app.put '/contracts/:contract_id/conditions/:condition_id/signatures/:signature_id' do

        contract_id = params[:contract_id]
        condition_id = params[:condition_id]
        signature_id = params[:signature_id]

        data = JSON.parse(request.body.read, :symbolize_names => true)

        signature = data[:signature]
        status = data[:status]

        if (contract_id != nil && contract_id != '') && (condition_id != nil && condition_id != '') && (signature_id != nil && signature_id != '')

          ContractService.new.update_condition(contract_id, condition_id, signature_id, signature, status)
          return  status 200
        end

        return status 404

      end
    end
  end
end
