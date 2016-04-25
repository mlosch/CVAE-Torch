require 'torch'
require 'cunn'

local CVAEv2 = {}

function CVAEv2.get_encoder(nc, ndf, latent_variable_size)
    -- The Encoder

    local encoder = nn.Sequential()
--    encoder:add(nn.SpatialConvolution(nc, ndf, 12, 12, 2, 2, 5, 5))
    encoder:add(nn.SpatialConvolution(nc, ndf, 4, 4, 2, 2, 1, 1))
    encoder:add(nn.SpatialBatchNormalization(ndf))
    encoder:add(nn.LeakyReLU(0.2, true))

    encoder:add(nn.SpatialConvolution(ndf, ndf * 2, 4, 4, 2, 2, 1, 1))
    encoder:add(nn.SpatialBatchNormalization(ndf * 2))
    encoder:add(nn.LeakyReLU(0.2, true))

    encoder:add(nn.SpatialConvolution(ndf * 2, ndf * 4, 4, 4, 2, 2, 1, 1))
    encoder:add(nn.SpatialBatchNormalization(ndf * 4))
    encoder:add(nn.LeakyReLU(0.2, true))
    encoder:add(nn.Dropout(0.2))

    encoder:add(nn.SpatialConvolution(ndf * 4, ndf * 8, 4, 4, 2, 2, 1, 1))
    encoder:add(nn.SpatialBatchNormalization(ndf * 8))
    encoder:add(nn.LeakyReLU(0.2, true))
    encoder:add(nn.Dropout(0.2))

    encoder:add(nn.View(ndf * 8 * 4 * 4))

    local mean_logvar = nn.ConcatTable()
    mean_logvar:add(nn.Linear(ndf * 8 * 4 * 4, latent_variable_size))
    mean_logvar:add(nn.Linear(ndf * 8 * 4 * 4, latent_variable_size))

    encoder:add(mean_logvar)

--    o = torch.rand(64, 3, 64, 64)
--    for i=1,#encoder.modules do
--        o = encoder.modules[i]:forward(o)
--        print(encoder.modules[i], #o)
--    end

    return encoder:cuda()
end

function CVAEv2.get_decoder(nc, ngf, latent_variable_size)
    -- The Decoder

    local decoder = nn.Sequential()
    decoder:add(nn.Linear(latent_variable_size, ngf * 8 * 4 * 4))
    decoder:add(nn.BatchNormalization(ngf * 8 * 4 * 4))
    decoder:add(nn.ReLU(true))
    decoder:add(nn.Dropout(0.2))
    decoder:add(nn.View(ngf * 8, 4, 4))

    decoder:add(nn.SpatialFullConvolution(ngf * 8, ngf * 4, 4, 4, 2, 2, 1, 1))
    decoder:add(nn.SpatialBatchNormalization(ngf * 4))
    decoder:add(nn.ReLU(true))
    decoder:add(nn.Dropout(0.2))

    decoder:add(nn.SpatialFullConvolution(ngf * 4, ngf * 2, 4, 4, 2, 2, 1, 1))
    decoder:add(nn.SpatialBatchNormalization(ngf * 2))
    decoder:add(nn.ReLU(true))

    decoder:add(nn.SpatialFullConvolution(ngf * 2, ngf, 4, 4, 2, 2, 1, 1))
    decoder:add(nn.SpatialBatchNormalization(ngf))
    decoder:add(nn.ReLU(true))

    local mean_logvar = nn.ConcatTable()
    mean_logvar:add(nn.SpatialFullConvolution(ngf, nc, 4, 4, 2, 2, 1, 1))
    mean_logvar:add(nn.SpatialFullConvolution(ngf, nc, 4, 4, 2, 2, 1, 1))
--    mean_logvar:add(nn.SpatialFullConvolution(ngf, nc, 12, 12, 2, 2, 5, 5))
--    mean_logvar:add(nn.SpatialFullConvolution(ngf, nc, 12, 12, 2, 2, 5, 5))
    decoder:add(mean_logvar)

--    decoder:add(nn.Tanh())

--    o = torch.rand(64, latent_variable_size)
--    for i=1,#decoder.modules do
--        o = decoder.modules[i]:forward(o)
--        print(decoder.modules[i], #o)
--    end
--    print(#o[1])

    return decoder:cuda()
end

return CVAEv2