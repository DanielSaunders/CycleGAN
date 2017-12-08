--------------------------------------------------------------------------------
-- Subclass of BaseDataLoader that provides data from two datasets.
-- The samples from the datasets are not aligned.
-- The datasets can have different sizes
--------------------------------------------------------------------------------
require 'data.base_data_loader'

local class = require 'class'
data_util = paths.dofile('data_util.lua')

UnalignedDataLoader = class('UnalignedDataLoader', 'BaseDataLoader')

function UnalignedDataLoader:__init(conf)
  BaseDataLoader.__init(self, conf)
  conf = conf or {}
end

function UnalignedDataLoader:name()
  return 'UnalignedDataLoader'
end

function UnalignedDataLoader:Initialize(opt)
  opt.align_data = 1
  self.idx_A = {1, opt.input_nc}
  self.idx_GT = {opt.input_nc+1, opt.input_nc+opt.output_nc}

  self.data = data_util.load_dataset('A', opt, 3)

  opt.align_data = 0
  self.dataB = data_util.load_dataset('B', opt, opt.output_nc)
end

-- actually fetches the data
-- |return|: a table of two tables, each corresponding to
-- the batch for dataset A and dataset B
function UnalignedDataLoader:LoadBatchForAllDatasets()
  local batch_data, pathA = self.data:getBatch()
  local batchA = batch_data[{ {}, self.idx_A, {}, {} }]
  local batchGT = batch_data[{ {}, self.idx_GT, {}, {} }]

  local batchB, pathB = self.dataB:getBatch()
  return batchA, batchB, batchGT, pathA, pathB
end

-- returns the size of each dataset
function UnalignedDataLoader:size(dataset)
  if dataset == 'A' then
    return self.data:size()
  end

  if dataset == 'B' then
    return self.dataB:size()
  end

  return math.max(self.data:size(), self.dataB:size())
  -- return the size of the largest dataset by default
end
