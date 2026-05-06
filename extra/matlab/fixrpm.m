function rpm_out = fixrpm(rpm)
% FIXRPM Fix Varian RPM data to interpolate missing timesteps
%    RPM_OUT = fixrpm (RPM)

%% This only works for interpolating single values
timediff = rpm.time(2:end)-rpm.time(1:end-1);
interp_idx = find (timediff > 1.4*median(timediff));

rpm_out.amp (1:interp_idx(1)) = rpm.amp (1:interp_idx(1));
rpm_out.phase (1:interp_idx(1)) = rpm.phase (1:interp_idx(1));
rpm_out.time (1:interp_idx(1)) = rpm.time (1:interp_idx(1));
rpm_out.valid (1:interp_idx(1)) = rpm.valid (1:interp_idx(1));
rpm_out.ttlin (1:interp_idx(1)) = rpm.ttlin (1:interp_idx(1));
rpm_out.mark (1:interp_idx(1)) = rpm.mark (1:interp_idx(1));
rpm_out.ttlout (1:interp_idx(1)) = rpm.ttlout (1:interp_idx(1));
out_pos = interp_idx(1);
for i=1:length(interp_idx)
  this_idx = interp_idx(i);
  next_idx = interp_idx(i)+1;
  interp_time = rpm.time(next_idx) - rpm.time(this_idx);
  interp_len = round(interp_time/0.033) - 1;
  for j=1:interp_len
    %% Add interpolated value
    rpm_out.amp(out_pos+j) = rpm.amp(this_idx) + j * (rpm.amp(next_idx) - rpm.amp(this_idx)) / interp_len;
    rpm_out.phase(out_pos+j) = rpm.phase(this_idx) + j * (rpm.phase(next_idx) - rpm.phase(this_idx)) / interp_len;
    while (rpm_out.phase(out_pos+j) > 2 * pi)
        %% Should do mod 2 pi interpolation here, but this may be enough
      rpm_out.phase(out_pos+j) = rpm_out.phase(out_pos+j) - 2 * pi;
    end
    rpm_out.time(out_pos+j) = rpm.time(this_idx) + 0.033 * j;
    rpm_out.valid(out_pos+j) = 0;
    rpm_out.ttlin(out_pos+j) = rpm.ttlin(this_idx);
    rpm_out.mark(out_pos+j) = 0;
    rpm_out.ttlout(out_pos+j) = rpm.ttlout(this_idx);
  end
  out_pos = out_pos + interp_len;

  %% Copy over values that don't need interpolation
  if i==length(interp_idx)
    nointerp_end = length(rpm.time);
  else
    nointerp_end = interp_idx(i+1);
  end
  nointerp_len = nointerp_end - next_idx + 1;

  rpm_out.amp(out_pos+(1:nointerp_len)) = rpm.amp(next_idx:nointerp_end);
  rpm_out.phase(out_pos+(1:nointerp_len)) = rpm.phase(next_idx:nointerp_end);
  rpm_out.time(out_pos+(1:nointerp_len)) = rpm.time(next_idx:nointerp_end);
  rpm_out.valid(out_pos+(1:nointerp_len)) = rpm.valid(next_idx:nointerp_end);
  rpm_out.ttlin(out_pos+(1:nointerp_len)) = rpm.ttlin(next_idx:nointerp_end);
  rpm_out.mark(out_pos+(1:nointerp_len)) = rpm.mark(next_idx:nointerp_end);
  rpm_out.ttlout(out_pos+(1:nointerp_len)) = rpm.ttlout(next_idx:nointerp_end);
  
  out_pos = out_pos + nointerp_len;
end

%% Copy over other values
rpm_out.header = rpm.header;
rpm_out.version = rpm.version;
