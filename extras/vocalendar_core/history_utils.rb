module VocalendarCore
  module HistoryUtils
    module Core
      def add_history(params = {})
        History.create history_default_param.merge(params)
      end
    end

    module Controller
      include Core
      def history_default_param
        {
          :target      => controller_name.singularize,
          :target_type => 'controller',
          :target_id   => params[:id],
          :action      => action_name,
          :user_id     => user_signed_in? ? current_user.id : nil,
        }
      end
    end

    module Model
      include Core
      def history_default_param
        {
          :target      => self.class.model_name.to_s.underscore,
          :target_type => 'model',
          :target_id   => self.id,
        }
      end
    end
  end
end

