require 'middleman-jspm/commands'
::Middleman::Extensions.register(:jspm) do
	require 'middleman-jspm/extension'
	::Middleman::JSPMExtension
end