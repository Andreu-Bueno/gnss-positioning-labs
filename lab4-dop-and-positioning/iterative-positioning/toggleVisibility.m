function toggleVisibility(event)

if strcmp(event.Peer.Visible, 'on')
    event.Peer.Visible = 'off';
    event.Peer.Color = [0.7 0.7 0.7]; % gris
else
    event.Peer.Visible = 'on';
    event.Peer.Color = event.Peer.UserData; % color original
end

end