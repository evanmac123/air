class User
  module Segmentation
    SEGMENTATION_CREATE_PRIORITY = 100
    SEGMENTATION_UPDATE_PRIORITY = 100 

    def values_for_segmentation
      {
        :ar_id                     => self.id,
        :demo_id                   => self.demo_id,
        :updated_at                => self.updated_at.utc,
        :points                    => self.points,
        :location_id               => self.location_id,
        :height                    => self.height,
        :weight                    => self.weight,
        :gender                    => self.gender,
        :characteristics           => self.characteristics.try(:stringify_keys) || {},
        :date_of_birth             => self.date_of_birth.try(:to_time).try(:utc).try(:midnight),
        :accepted_invitation_at    => self.accepted_invitation_at.try(:utc),
        :claimed                   => self.accepted_invitation_at.present?,
        :has_phone_number          => self.phone_number.present?,
        :email_has_internal_domain => self.email_has_internal_domain?,
      }
    end

    def segmentation_data
      SegmentationData.where(:ar_id => self.id).first
    end

    def set_segmentation_results!(columns, operators, values, demo)
      explanation = create_segmentation_explanation(columns, operators, values)
      ids = load_segmented_user_information(columns, operators, values, demo)
      User::SegmentationResults.create_or_update_from_search_results(self, explanation, ids)
    end

    def segmentation_results
      User::SegmentationResults.where(:owner_id => self.id).first
    end

    def rebuild_segmentation_data!
      self.segmentation_data.destroy
      self.schedule_segmentation_create
    end

    def self.rebuild_all_segmentation_data!
      User.all.each(&:"rebuild_segmentation_data!")
    end

    protected

    def cast_characteristics
      return unless changed.include?('characteristics')

      self.characteristics.keys.each do |characteristic_id|
        characteristic = Characteristic.find(characteristic_id)
        self.characteristics[characteristic_id] = characteristic.cast_value(characteristics[characteristic_id])
      end
    end

    def schedule_segmentation_create
      self.delay(priority: SEGMENTATION_CREATE_PRIORITY).create_segmentation_info
    end

    def schedule_segmentation_update(force = false)
      return unless force || FIELDS_TRIGGERING_SEGMENTATION_UPDATE.any?{|field_name| changed.include?(field_name)}

      self.delay(priority: SEGMENTATION_UPDATE_PRIORITY).update_segmentation_info(force)
    end

    def create_segmentation_info
      User::SegmentationData.create_from_user(self)
    end

    def update_segmentation_info(force = false)
      User::SegmentationData.update_from_user(self, force)
    end

    def destroy_segmentation_info
      User::SegmentationData.destroy_from_user(self)
    end

    def create_segmentation_explanation(columns, operators, values)
      unless values.present?
        return 'No segmentation, choosing all users'
      end

      segmentation_explanation = "Segmenting on:"
      prefix = ''

      columns.each do |index, characteristic_id|
        characteristic = Characteristic.find(characteristic_id)
        segmentation_explanation += [prefix, characteristic.name, operators[index], Characteristic.find(characteristic_id).format_value(values[index])].join(' ')
        prefix = ','
      end

      segmentation_explanation
    end

    def load_segmented_user_information(columns, operators, values, demo)
      query = User::SegmentationData

      unless demo.nil?
        query = query.where(:demo_id => demo.id)
      end
    
      if values.present?
        columns.each do |index, characteristic_id|
          casted_value = Characteristic.find(characteristic_id).cast_value(values[index])
          query = User::SegmentationOperator.add_criterion_to_query!(query, characteristic_id, operators[index], casted_value)
        end
        query.map(&:ar_id)
      else
        demo.user_ids
      end
    end
  end
end
