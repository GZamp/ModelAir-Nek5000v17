$(OBJDIR)/frame.o              :frame.f;                                $(F77) -c $(FL2) -I./ $< -o $@
$(OBJDIR)/frame_usr.o          :frame_usr.f;                            $(F77) -c $(FL2) -I./ $< -o $@
$(OBJDIR)/io_tools_block.o     :io_tools_block.f;                       $(F77) -c $(FL2) -I./ $< -o $@
$(OBJDIR)/io_tools.o           :io_tools.f;                             $(F77) -c $(FL2) -I./ $< -o $@
$(OBJDIR)/mntrlog_block.o      :mntrlog_block.f MNTRLOGD;               $(F77) -c $(FL2) -I./ $< -o $@
$(OBJDIR)/mntrlog.o            :mntrlog.f MNTRLOGD;                     $(F77) -c $(FL2) -I./ $< -o $@
$(OBJDIR)/mntrtmr_block.o      :mntrtmr_block.f MNTRLOGD MNTRTMRD;      $(F77) -c $(FL2) -I./ $< -o $@
$(OBJDIR)/mntrtmr.o            :mntrtmr.f MNTRLOGD MNTRTMRD FRAMELP;    $(F77) -c $(FL2) -I./ $< -o $@
$(OBJDIR)/rprm_block.o         :rprm_block.f RPRMD;                     $(F77) -c $(FL2) -I./ $< -o $@
$(OBJDIR)/rprm.o               :rprm.f RPRMD FRAMELP;                   $(F77) -c $(FL2) -I./ $< -o $@
$(OBJDIR)/map2D.o              :map2D.f MAP2D FRAMELP;                  $(F77) -c $(FL2) -I./ $< -o $@
$(OBJDIR)/stat.o               :stat.f STATD MAP2D FRAMELP;             $(F77) -c $(FL2) -I./ $< -o $@
$(OBJDIR)/stat_IO.o            :stat_IO.f STATD MAP2D FRAMELP;          $(F77) -c $(FL2) -I./ $< -o $@
$(OBJDIR)/chkpoint.o           :chkpoint.f CHKPOINTD;                   $(F77) -c $(FL2) -I./ $< -o $@
$(OBJDIR)/chkpt_mstp.o         :chkpt_mstp.f CHKPTMSTPD;                $(F77) -c $(FL2) -I./ $< -o $@
$(OBJDIR)/trip.o               :trip.f TRIPD;                           $(F77) -c $(FL2) -I./ $< -o $@
$(OBJDIR)/tsrs.o               :tsrs.f TSRSD FRAMELP;                   $(F77) -c $(FL2) -I./ $< -o $@
$(OBJDIR)/tsrs_IO.o            :tsrs_IO.f TSRSD;                        $(F77) -c $(FL2) -I./ $< -o $@
$(OBJDIR)/pts_redistribute.o   :pts_redistribute.f TSRSD;               $(F77) -c $(FL2) -I./ $< -o $@
