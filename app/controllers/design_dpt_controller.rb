class DesignDptController < ApplicationController

  def update_design_changes(vdm, newVdm)
    changes = []
    assignment= {}
    if newVdm['dAsigned'] != nil
      if newVdm['role'] == 'designLeader'
        assignment = vdm.design_dpt.design_assignment
        if assignment == nil
          assignment = DesignAssignment.new
        end
        assignment.design_dpt_id = vdm.design_dpt.id
        assignment.user_id = newVdm['dAsigned']['id']
        assignment.assignedName = newVdm['dAsigned']['name']
        assignment.status = 'asignado'
        assignment.save!
        user = User.find(newVdm['dAsigned']['id'])
        UserNotifier.send_assigned_to_designer(vdm, user.employee).deliver
        change = VdmChange.new
        change.changeDetail = "Asignado video a diseñador " + newVdm['dAsigned']['name']
        change.vdm_id = vdm.id
        change.user_id = $currentPetitionUser['id']
        change.uname = $currentPetitionUser['username']
        change.videoId = vdm.videoId
        change.changeDate = Time.now
        change.department = 'diseño'
        changes.push(change)
      end
    end
    if newVdm['designDept'] != nil
      if newVdm['designDept']['assignment']
        if newVdm['role'] == 'designer'
          if vdm.design_dpt.design_assignment.comments != newVdm['designDept']['assignment']['comments']
            change = VdmChange.new
            change.changeDetail = "Cambio de comentarios de diseñador"
            if vdm.design_dpt.design_assignment.comments != nil
              change.changedFrom = vdm.design_dpt.design_assignment.comments
            else
              change.changedFrom = "vacio"
            end
            change.changedTo = newVdm['designDept']['assignment']['comments']
            change.vdm_id = vdm.id
            change.user_id = $currentPetitionUser['id']
            change.uname = $currentPetitionUser['username']
            change.videoId = vdm.videoId
            change.changeDate = Time.now
            change.department = 'diseño'
            changes.push(change)
            vdm.design_dpt.design_assignment.comments = newVdm['designDept']['assignment']['comments']
            vdm.design_dpt.design_assignment.save!
          end
          if vdm.design_dpt.design_assignment.status != newVdm['designDept']['assignment']['status']
            if newVdm['designDept']['assignment']['status'] != 'no asignado'
              change = VdmChange.new
              change.changeDetail = "Cambio de estado de diseñador"
              if vdm.design_dpt.design_assignment.status != nil
                change.changedFrom = vdm.design_dpt.design_assignment.status
              else
                change.changedFrom = "vacio"
              end
              change.changedTo = newVdm['designDept']['assignment']['status']
              change.vdm_id = vdm.id
              change.user_id = $currentPetitionUser['id']
              change.uname = $currentPetitionUser['username']
              change.videoId = vdm.videoId
              change.changeDate = Time.now
              change.department = 'diseño'
              changes.push(change)
              vdm.design_dpt.design_assignment.status = newVdm['designDept']['assignment']['status']
              vdm.design_dpt.design_assignment.save!
              if vdm.design_dpt.design_assignment.status == 'diseñado'
                UserNotifier.send_to_approved_to_designLeader(vdm).deliver
              end
            end
          end
          assignment = vdm.design_dpt.design_assignment
        end
      end
    end

    VdmChange.transaction do
      changes.uniq.each(&:save!)
    end
    design_payload = {
        status: vdm.design_dpt.status,
        comments: vdm.design_dpt.comments,
        assignment: assignment
    }
    return design_payload
  end
end
